package k2d;

import k2d.input.Keyboard;
import k2d.utils.GameStats;
import k2d.math.Random;
import k2d.math.FastFloat;
import k2d.render.IRenderer;
import k2d.render.Renderer;
import k2d.render.Framebuffer;
import k2d.tween.TweenManager;
import k2d.timer.TimerManager;

//todo functional game options
typedef GameOptions = {
    @:optional var randomSeed:Null<Int>;
    @:optional var transparent:Null<Bool>;
    @:optional var backgroundColor:Color;
}

class Game {
    #if debug
    public var debugStats = new GameStats();
    #end

    public var title:String;
    
    public var width(get, set):Int;
    private var _width:Int = 0;

    public var height(get, set):Int;
    private var _height:Int = 0;

    public var renderers:Array<RenderAction<Dynamic>> = [];

    public var sceneManager:SceneManager;
    public var scene(get, set):Scene;

    public var isRunning(get, null):Bool;

    private var _loop:Loop = new Loop();
    private var _initiated:Bool = false;

    public function onInit() { }

    private var _backbuffer:kha.Image;

    public function new(title:String, width:Int = 0, height:Int = 0, ?options:GameOptions) {
        this.title = title;
        this.width = width;
        this.height = height;

        if(options != null && options.randomSeed != null){
            Random.init(options.randomSeed);
        }else{
            #if debug 
            Random.init(1);
            #else
            Random.init(Std.int(Date.now().getTime()));
            #end
        }
        
        sceneManager = new SceneManager(this);

        addRenderer("2d", new Renderer(), _render2D);
    }
    
    public function run() {
        kha.System.init({
            title: title,
            width: width,
            height: height
        }, function onRun() {
            _backbuffer = k2d.resources.Image.createRenderTarget(width, height);
            kha.System.notifyOnRender(_render);
            System.subscribeOnSystemUpdate(_systemUpdate);
            _loop.onTick(_update);
        });
    }

    @:generic public function addRenderer<T:IRenderer>(id:String, renderer:T, action:T->Void){
        if(_initiated){
            throw new Error("Renderers must be added before onInit.");
            return;
        }

        //TODO addRenderers could be added at compilation time by macros
        var rAction:RenderAction<T> = {
            id: id,
            renderer: renderer,
            action: action
        };

        var index = _getRendererIndex(id);
        if(index == -1) {
            renderers.push(rAction);
            return;
        }

        renderers[index] = rAction;
    }

    private inline function _getRendererIndex(id:String) : Int {
        var index = -1;
        for(i in 0...renderers.length){
            if(renderers[i].id == id){
                index = i;
                break;
            }
        }

        return index;
    }

    @:generic public function getRenderer<T:IRenderer>(id:String, type:Class<T>) : T {
        var r:T = null;
        for(rAction in renderers){
            if(rAction.id == id){
                r = cast rAction.renderer;
                break;
            }
        }

        return r;
    }

    public function start() {
        if(!_initiated){ return; }
        if(isRunning){ return; }

        //Movie.unpauseAll();
        _loop.start();
        System.start();
    }

    public function stop() {
        if(!_initiated){ return; }
        if(!isRunning){ return; }

        //Movie.pauseAll();
        _loop.stop();
        System.stop();
    }

    #if kha_js 
    public function getCanvas() : js.html.CanvasElement {
        return cast js.Browser.document.getElementById(kha.CompilerDefines.canvas_id);
    }
    #else
    public function getCanvas() : Dynamic {
        return null;
    }
    #end

    private function _systemUpdate() {
        #if debug
        debugStats.system.tick();
        #end
    }

    private function _update(delta:FastFloat) {
        #if debug
        debugStats.update.tick();
        #end
        
        update(delta);

        if(Keyboard.isEnabled){
            Keyboard.update(delta);
        }
    }

    public function update(delta:FastFloat) {
        TimerManager.Global.update(delta);
        TweenManager.Global.update(delta);
        
        sceneManager.update(delta);
    }

    private function _render(framebuffer:Framebuffer) {
        #if debug
        debugStats.renderer.tick();
        #end

        _init();

        if(!isRunning){
            return;
        }

        for(rAction in renderers){
            rAction.renderer.g2 = _backbuffer.g2;
            rAction.renderer.g4 = _backbuffer.g4;
            rAction.action(rAction.renderer);
        }

        framebuffer.g2.begin();
        framebuffer.g2.drawImage(_backbuffer, 0, 0);
        framebuffer.g2.end();
    }

    private function _render2D(r:Renderer) {
        r.begin();
        render(r);
        r.end();
    }

    public function render(renderer:Renderer){
        sceneManager.render(renderer);
        renderer.reset();
    }

    private inline function _init() {
        if(_initiated || renderers.length == 0){ return; }

        _initiated = true;

        onInit();
        start();
    }

    function get_isRunning() : Bool {
		return _loop.isRunning;
	}

    function get_width() : Int {
        return _width;
    }

    function set_width(v:Int) : Int {
        //todo manage resize events in html and native
        #if kha_js
        if(v <= 0) {
            //todo set screen size in desktop?
            v = js.Browser.window.innerWidth;
        }
        #end

        if(!_initiated){
            #if kha_js
            var canvas = getCanvas();
            if(canvas != null){
                canvas.width = v;
                canvas.style.width = v + "px";
            }
            #end
        }
        return _width = v;
    }

    function get_scene() : Scene {
        return sceneManager.scene;
    }

    function set_scene(scene:Scene) : Scene {
        sceneManager.scene = scene;
        return scene;
    }

    function get_height() : Int {
        return _height;
    }

    function set_height(v:Int) : Int {
        //todo manage resize events in html and native
        #if kha_js
        if(v <= 0) {
            //todo set screen size in desktop?
            v = js.Browser.window.innerHeight;
        }
        #end

        if(!_initiated){
            #if kha_js
            var canvas = getCanvas();
            if(canvas != null){
                canvas.height = v;
                canvas.style.height = v + "px";
            }
            #end
        }
        return _height = v;
    }
}