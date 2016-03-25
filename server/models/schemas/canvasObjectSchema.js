//users.js mongoose schema definintion
var mongoose = require( 'mongoose' ); 

var options = { discriminatorKey: 'type' };
function schemaBase(type) {

    var schema = new mongoose.Schema(
    	{ 
    		project_id: {type: mongoose.Schema.Types.ObjectId,
                ref: 'Project' }
            ,position: 
                {type: 
                    { x: { type: Number, require: true }
                    , y: { type: Number, require: true }
                    }
                , required: true }
    		, registered : { type: Date, default: Date.now } //Timezone is strange
            , type: {type: String, require: true}
            , dimensions: 
                {type: 
                    { width: { type: Number, require: true }
                    , height: { type: Number, require: true }
                }
            }
    	}
    ); 

    if(type == "text"){
        schema.add({
            text: {type: String, default: "new textBox", require: true}
            , style : {type: String, default: "paragraf", require: true}
            , position: 
                {type: 
                    { x: { type: Number, require: true }
                    , y: { type: Number, require: true }
                }
            }
            
        })
    }else if(type == "file") {
        schema.add({
            name: {type: String, require: true}
            ,webViewLink: {type: String, require: true}
            ,iconLink: {type: String, require: true}
            ,thumbnailLink: {type: String, require: true}
            ,driveId: {type: String, require:true}
        })
    }
    return schema;
}

// var test = schemaBase();
// console.log(test);

var CanvasObject = mongoose.model('CanvasObject', schemaBase());

var TextObject = mongoose.model('TextObject', schemaBase("text"), 'CanvasObject');

var FileObject = mongoose.model('FileObject', schemaBase("file"), 'CanvasObject');

//var TextObject = mongoose.model('TextObject', TextObjectSchema);

exports.CanvasObject = CanvasObject;
exports.TextObject = TextObject;
exports.FileObject = FileObject;
