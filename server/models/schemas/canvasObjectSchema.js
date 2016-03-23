//users.js mongoose schema definintion
var mongoose = require( 'mongoose' ); 

var options = { discriminatorKey: 'type' };
var CanvasObjectSchema = new mongoose.Schema(
	{ 
		project_id: {type: mongoose.Schema.Types.ObjectId,
            ref: 'Project' }
        ,position: 
            {type: 
                { x: { type: Number, require: true }
                , y: { type: Number, require: true }
                }
            , required: true },
		registred : { type: Date, default: Date.now } //Timezone is strange
	}, options
);

var CanvasObject = mongoose.model('CanvasObject', CanvasObjectSchema);

var TextObject = CanvasObject.discriminator('Text'
    , new mongoose.Schema({
        text : {type: String, require: true}
        , style : {type: String, default: "paragraf", require: true}// will be a foreign key to Style!
    }, options)
)

var FileObject = CanvasObject.discriminator('File'
    , new mongoose.Schema({
        fileURI : {type: String, require: true}
        , imageURI : {type: String, default: "imageURI", require: true}// will be a foreign key to Style!
    }, options)
)

//var TextObject = mongoose.model('TextObject', TextObjectSchema);

exports.CanvasObject = CanvasObject;
exports.TextObject = TextObject;
exports.FileObject = FileObject;
