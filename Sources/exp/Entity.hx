package exp;

class Entity {
    public var id:String = "";
    public var name:String = "";
    public var manager:EntityManager;

    private var _components:Map<String,Component> = new Map<String, Component>();

    private var _addHandlers:Array<Entity->Component->Void> = [];
    private var _removeHandlers:Array<Entity->Component->Void> = [];

    public function new(id:String = "", name:String = "") {
        this.id = id;
        this.name = name == "" ? Type.getClassName(Type.getClass(this)) : name;
    }

    public function addComponent(component:Component) : Entity {
        _components.set(component._typ, component);
        _dispatchAddComponent(this, component);
        return this;
    }

    public function removeComponent<T:Component>(componentClass:Class<T>) : T {
        var name = Type.getClassName(componentClass);
        var c:T = cast _components.get(name);
        if(c != null){
            _components.remove(name);
            _dispatchRemoveComponent(this, c);
            return c;
        }
        return null;
    }

    public function getComponent<T:Component>(componentClass:Class<T>) : T {
        return cast _components.get(Type.getClassName(componentClass));
    }

    public function hasComponent(componentClass:Class<Component>) : Bool {
        return _components.exists(Type.getClassName(componentClass));
    }


    public function onAddComponent(handler:Entity->Component->Void) {
        _addHandlers.push(handler);
    }

    public function offAddComponent(handler:Entity->Component->Void) {
        _addHandlers.remove(handler);
    }

    public function onRemoveComponent(handler:Entity->Component->Void) {
        _removeHandlers.push(handler);
    }

    public function offRemoveComponent(handler:Entity->Component->Void) {
        _removeHandlers.remove(handler);
    }

    private function _dispatchAddComponent(entity:Entity, component:Component) {
        for(handler in _addHandlers){
            handler(entity, component);
        }
    }

    private function _dispatchRemoveComponent(entity:Entity, component:Component) {
        for(handler in _removeHandlers){
            handler(entity, component);
        }
    }
}