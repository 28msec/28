'use strict';

exports.Client = {
    OVERWRITE_ALWAYS: 0,
    OVERWRITE_NEVER: 1,
    OVERWRITE_ASK: 2,
    OVERWRITE_IF_NEWER: 3,
    
    overwriteCoercion: function(value, cmd){
        value = value.toLowerCase();
        if(value === 'yes' || value === 'all' || value === 'always') {
            return this.OVERWRITE_ALWAYS;
        }else if(value === 'no' || value === 'none' || value === 'never') {
            return this.OVERWRITE_NEVER;
        } else if(value === 'ask') {
            return this.OVERWRITE_ASK;
        } else if(value === 'if-newer') {
            return this.OVERWRITE_IF_NEWER;
        } else {
            console.error('Invalid option value for overwrite.'.red);
            cmd.help();
        }
    }
};