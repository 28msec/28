import module namespace req = "http://www.28msec.com/modules/http/request";
import module namespace res = "http://www.28msec.com/modules/http/response";

declare variable $keyword-map := {
(:    default: "difault" :)
};

declare function local:camel-case($name as string) as string {
    let $name := if(exists($keyword-map($name))) then
$keyword-map($name) else $name
    let $tokens :=
        for $token at $i in tokenize($name, "-")
        return (
            if($i eq 1) then
                lower-case(substring($token, 1, 1))
            else
                upper-case(substring($token, 1, 1))
        ) || substring($token, 2)
    return string-join($tokens, "")
};

declare function local:signature($parameters as object*) as string {
    string-join(
        for $parameter in $parameters
        where not($parameter.paramType eq "header" and
jn:size($parameter.enum) eq 1)
        return local:camel-case($parameter.name)
    , ", ")
};

declare function local:queries($parameters as object*) as object* {
    for $param in $parameters
    where $param.paramType eq "query"
    return $param
};

declare function local:singletons($parameters as object*) as object*{
    for $parameter in $parameters
    where jn:size($parameter.enum) eq 1
    return {
        "key": local:camel-case($parameter.name),
        "value": $parameter.enum()[1]
    }
};

declare function local:path($path as string, $parameters as object*) as string {
    let $segments :=
        for $segment in $parameters
        where $segment.paramType eq "path"
        return $segment.name
    return
        local:compute-path($path, $segments) };

declare function local:compute-path($path as string, $segments as string*) as string {
    if(empty($segments)) then
        "'" || $path || "'"
    else
        let $segment := $segments[1]
        let $new-path := replace(
            $path, "\\{" || $segment || "\\}", "' + parameters['" || local:camel-case($segment) || "'] + '"
        )
        return local:compute-path(
            $new-path,
            subsequence($segments, 2)
        )
};

declare function local:has-body($parameters as object*) as boolean {
    exists(
        for $param in $parameters
        where $param.paramType eq "body"
        return $param
    )
};

declare function local:has-headers($parameters as object*) as boolean {
    exists(
        for $param in $parameters
        where $param.paramType eq "header"
        return $param
    )
};

declare function local:javascript($d as object, $new-module as boolean) as string {
"angular.module('" || $d.module || "'" || (if($new-module) then ", []" else "") || ")
/**
 * " || (if($d.doc.description) then $d.doc.description else "Description Missing") || "
 */
.factory('" || $d.service || "', function($q, $http, $rootScope){
    /**
     * @class " || $d.service || "
     * @param {string} domain - The project domain
     */
    return function(domain) {
        if(typeof(domain) !== 'string') {
            throw new Error('Domain parameter must be specified as a string.');
        }

        var root = '" || $d.doc.resourcePath || "';

        this.$on = function($scope, path, handler) {
            var url = domain + path;
            $scope.$on(url, function(event, data){
                handler(data);
            });
            return this;
        };

        this.$broadcast = function(path, data){
            var url = domain + path;
            $rootScope.$broadcast(url, data);
            return this;
        };

" || string-join(
        for $operation in $d.operations()

        return "        /**
         * " || $operation.doc.notes || "
         * @method
         * @name " || $d.service || "#" || $operation.name || "
         * " || string-join(for $param in $operation.doc.parameters() return "@param {" || $param.type || "} " || $param.name || " - " || $param.description || ",
         * ")|| "
         */
        this." || $operation.name || " = function(parameters){
            var deferred = $q.defer();" ||
        string-join(for $singleton in $operation.singletons()
        return "
            var " || $singleton.key || " = '" || $singleton.value || "';", "
        ")
        || "
            var that = this;
            var path = " || $operation.path || "
            var url = domain + path;
            var params = {};
            " ||
        string-join(for $query in $operation.queries()
        return if($query.required eq false) then
        if(exists($query.pattern)) then
            "for(var prop in parameters)
                if (parameters.hasOwnProperty(prop))
                    if(/^" || $query.pattern || "$/ig.test(prop))
                        params[prop]=parameters[prop];"
        else "params['" || $query.name || "'] = parameters['" || local:camel-case($query.name) || "'];"
        else "if(parameters['" || local:camel-case($query.name) || "'] === undefined) {
                deferred.reject(new Error('The " || local:camel-case($query.name) || " parameter is required'));
                return deferred.promise;
            } else {
                params['" || $query.name || "'] = parameters['" || local:camel-case($query.name) || "'];
            }", "
            ")
            ||
        (if($operation.hasBody)
        then "
            var body = parameters['" || $operation.body || "'];"
        else "
            var body = null;")
            || "
            var method = '" || $operation.method || "'.toUpperCase();
            if (parameters.$method)
            {
                params['_method'] = parameters.$method;
                method = '" || (if($operation.hasBody) then "POST" else "GET") || "';
            }
            var cached = parameters.$cache && parameters.$cache.get(url);
            if(method === 'GET' && cached !== undefined && parameters.$refresh !== true) {
                deferred.resolve(cached);
            } else {
            $http({
                method: method,
                url: url,
                params: params" || (if($operation.hasBody) then ",
data: body" else "")  || (if($operation.hasHeaders) then ", headers: "
|| $operation.headers else "") || ",
                cache: (parameters.$refresh !== true)
            })
            .success(function(data, status, headers, config){
                deferred.resolve(data);
                " || (
                        if($operation.method eq "POST" or $operation.method eq "PUT" or $operation.method eq "DELETE" or $operation.method eq "PATCH") then
                             "//cache.removeAll();"
                        else if($operation.method eq "GET") then
                            "//that.$broadcast(url);
                if(parameters.$cache !== undefined) parameters.$cache.put(url, data, parameters.$cacheItemOpts ?
parameters.$cacheItemOpts : {});"
                        else ""
                    ) || "
            })
            .error(function(data, status, headers, config){
                deferred.reject({data: data, status: status, headers: headers, config: config});" || "
                //cache.removeAll();
            })
            ;
            }
            return deferred.promise;
        };"
        , "

") || "
    };
});"
};

res:set-content-type("text/plain");

let $input :=
let $doc     := jn:parse-json(req:text-content())
let $module  := req:parameter-values("module") let $service := req:parameter-values("service") return {
    doc: $doc,
    module: $module,
    service: $service,
    operations: [
        for $api in $doc.apis()
        for $operation in $api.operations()
        return  {
            doc: $operation,
            name: $operation.nickname,
            method: $operation.method,
            signature: local:signature($operation.parameters()),
            queries: [local:queries($operation.parameters())],
            singletons: [local:singletons($operation.parameters())],
            path: local:path($api.path, $operation.parameters()),
            hasBody: local:has-body($operation.parameters()),
            hasHeaders: local:has-headers($operation.parameters()),
            headers: "{" ||
                (
                    for $param in $operation.parameters()
                    where $param.paramType eq "header"
                    return "'" || $param.name || "': parameters['" || local:camel-case($param.name) || "']"
                )
            || "}",
            body:
                for $param in $operation.parameters()
                where $param.paramType eq "body"
                return local:camel-case($param.name)
        }
    ]
}
return
    local:javascript($input,(string-join(req:parameter-values("new-module", "true"), "") cast as boolean))
