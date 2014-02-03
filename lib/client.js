'use strict';

var Client = {

    OVERWRITE_ALWAYS: 0,
    OVERWRITE_NEVER: 1,
    OVERWRITE_ASK: 2,
    OVERWRITE_IF_NEWER: 3,

    download: function(remote, local, overwrite, deleteOrphaned, simulate){
        console.log(remote);
        console.log(local);
        console.log(overwrite);
        console.log(deleteOrphaned);
        console.log(simulate);
        return;
        Objects.keys(remote).forEach(function(file){
            //Check if local file exists
            if(local[file]) {
                
            }
            //If local file exists resolve according to the overwrite value
            console.log(fs.existsSync(file.path));
            console.log();
            
        });
        if(deleteOrphaned) {
            local.forEach(function(file){
                //Check if remote file exists
                //If not, delete
            });
        }
        console.log(remote);
        console.log(local);
        console.log(overwrite);
        console.log(deleteOrphaned);
    }
};

module.exports = Client;