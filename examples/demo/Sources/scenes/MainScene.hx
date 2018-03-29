package scenes;

import gecko.Graphics;
import gecko.Scene;
import gecko.Gecko;
import gecko.Color;
import gecko.components.input.MouseComponent;
import gecko.components.draw.NineSliceComponent;
import gecko.Float32;
import gecko.Screen;
import gecko.Entity;
import gecko.math.Point;
import gecko.components.draw.TextComponent;
import gecko.Transform;

import scenes.DrawSpriteScene;
import scenes.DrawTextScene;
import scenes.DrawShapeScene;
import scenes.DrawNineSliceScene;
import scenes.DrawScrollingSpriteScene;

typedef ExamplesDef = {
    name:String,
    callback:Void->Void
};

@:expose
class MainScene extends CustomScene {
    static var _examples:Array<ExamplesDef> = [];

    override public function init(closeButton:Bool = false) {
        trace("start init main scene");
        super.init(closeButton);

        _addTitle(Screen.centerX, 60);

        //buttons and scenes to go
        _initExamples();

        //create buttons
        var minX = 140;
        var minY = 150;

        var gapX = 175;
        var gapY = 60;

        var xx = minX;
        var yy = minY;

        for(example in _examples){
            _createButton(example.name, xx, yy, function(x, y){
               example.callback();
            });

            yy += gapY;

            if(yy > Screen.height-60){
                xx += gapX;
                yy = minY;
            }
        }

        trace("end init mainscene");
    }

    override public function beforeDestroy() {
        super.beforeDestroy();

        _examples = [];
    }

    private function _initExamples() {
        if(_examples.length == 0){
            trace("INIT");
            _examples = [
                {
                    name: "Draw Sprites",
                    callback: function() {
                        _gotoScene(DrawSpriteScene.create(true));
                    }
                },
                {
                    name: "Draw Shapes",
                    callback: function() {
                        _gotoScene(DrawShapeScene.create(true));
                    }
                },
                {
                    name: "Draw Animations",
                    callback: function(){

                    }
                },
                {
                    name: "Draw NineSlices",
                    callback: function() {
                        _gotoScene(DrawNineSliceScene.create(true));
                    }
                },
                {
                    name: "Draw ScrollingSprites",
                    callback: function() {
                        _gotoScene(DrawScrollingSpriteScene.create(true));
                    }
                },
                {
                    name: "Draw Text",
                    callback: function(){
                        _gotoScene(DrawTextScene.create(true));
                    }
                },
                {
                    name: "Transform Rotation",
                    callback: function(){

                    }
                },
                {
                    name: "Transform Anchors",
                    callback: function(){

                    }
                },
                {
                    name: "Transform Pivots",
                    callback: function(){

                    }
                },
                {
                    name: "Transform Skew",
                    callback: function(){

                    }
                },
                {
                    name: "Transform Pivot",
                    callback: function(){

                    }
                },
                {
                    name: "Transform Parents",
                    callback: function(){

                    }
                },
            ];
        }
    }

    private function _gotoScene(scene:Scene){
        Gecko.world.changeScene(scene, true);
    }

    private function _createButton(text:String, x:Float32, y:Float32, callback:Float32->Float32->Void) {
        //Button sprite
        var btn = Entity.create();
        btn.transform.position.set(x, y);

        var nineSlice = btn.addComponent(NineSliceComponent.create("images/kenney/green_panel.png", 160, 50));

        //button text
        var txt = Entity.create();
        txt.transform.position.set(x, y);
        txt.addComponent(TextComponent.create(text, "Ubuntu-B.ttf", 20));

        //Text must be inside the text
        var maxWidth = btn.transform.width - 20;
        if(txt.transform.width > maxWidth){
            var scale = maxWidth/txt.transform.width;
            txt.transform.scale.set(scale, scale);
        }

        //over and out color effect
        var mouse = btn.addComponent(MouseComponent.create());
        mouse.onOver += function(x:Float32, y:Float32) {
            nineSlice.color = Color.LightGreen;
        };

        mouse.onOut += function(x:Float32, y:Float32){
            nineSlice.color = Color.White;
        };

        //trigger the callback when the button it's clicked
        mouse.onClick += callback;

        mouse.onMove += function(x,y){
            trace(mouse.entity.id, x,y);
        };

        //add the entities to this scene
        addEntity(btn);
        addEntity(txt);
    }

    private function _addTitle(x:Float32, y:Float32) {
        var entity = Entity.create();
        entity.transform.position.set(x, y);
        entity.addComponent(TextComponent.create("Gecko2D Demo", "Ubuntu-B.ttf", 70));
        addEntity(entity);
    }
}