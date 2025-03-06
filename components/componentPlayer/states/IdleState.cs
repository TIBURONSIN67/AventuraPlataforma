using Godot;

namespace BatteryRush.components.componentPlayer.states
{
    public class IdleState : IState
    {
        private readonly Player _player;

        public IdleState(Player player)
        {
            _player = player;
        }

        public void Enter()
        {
            GD.Print("Entrando en Idle");
        }

        public void Update(float delta)
        {
            if (!_player.IsOnFloor() && !_player.RaycastIsColliding())
            {
                _player.CanJump = true;
                _player.ChangeState("Fall");
                return;
            }

            _player.InputKey = Vector3.Zero;
            _player.Gravity = _player.DefaultGravity;
            _player.ChangeAnimMoveState("Idle");

            if (_player.CheckPcMoveInputs())
            {
                _player.ChangeState("Walk");
            }
            else if (Input.IsActionPressed("jump"))
            {
                _player.ChangeState("Jump");
            }

        }

        public void Exit()
        {
            GD.Print("Saliendo de Idle");
        }
    }
}