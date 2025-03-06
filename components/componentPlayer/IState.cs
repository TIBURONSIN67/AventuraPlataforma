namespace BatteryRush.components.componentPlayer;

// Interfaz de estados
public interface IState
{
    void Enter();
    void Update(float delta);
    void Exit();
}