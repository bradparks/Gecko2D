package exp.components;

import exp.macros.IAutoPool;
import exp.utils.Event;

//todo macro clone all fields to use with prefabs

@:allow(exp.Entity)
#if !macro
@:build(exp.macros.TypeInfoBuilder.buildComponent())
@:autoBuild(exp.macros.TypeInfoBuilder.buildComponent())
#end
class Component implements IAutoPool {
    public var entity(get, set):Entity;
    private var _entity:Entity = null;

    public var id:Int = Gecko.getUniqueID();
    public var enabled:Bool = true;

    public var name(get, set):String;
    private var _name:String = "";

    public var onAddedToEntity:Event<Entity->Void>;
    public var onRemovedFromEntity:Event<Entity->Void>;

    public function new(){
        onAddedToEntity = Event.create();
        onRemovedFromEntity = Event.create();
    }

    public function init(name:String = "") {
        _name = name;
    }
    public function reset(){}

    public function destroy(avoidPool:Bool = false) {
        reset();
        if(entity != null){
            entity.removeComponent(__type__);
        }
        if(!avoidPool)__toPool__();
    }

    private function __toPool__() {} //macros

    inline function get_name():String {
        return _name == "" ? __typeName__ : _name;
    }

    inline function set_name(value:String):String {
        return this._name = value;
    }

    inline function get_entity():Entity {
        return _entity;
    }

    function set_entity(value:Entity):Entity {
        if(_entity == value)return _entity;

        var e = _entity;
        _entity = value;

        if(e != null){
            onRemovedFromEntity.emit(e);
        }

        if(_entity != null){
            onAddedToEntity.emit(_entity);
        }

        return _entity;
    }
}