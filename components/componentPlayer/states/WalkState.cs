using Godot;

namespace BatteryRush.components.componentPlayer.states
{
    public class WalkState : IState
    {
        private readonly Player _player;

        public WalkState(Player player)
        {
            _player = player;
        }

        public void Enter()
        {
            GD.Print("Entrando en Walk");
        }

        public void Update(float delta)
        {
            if (!_player.IsOnFloor() && !_player.RaycastIsColliding())
            {
                _player.CanJump = true;
                _player.ChangeState("Fall");
                return;
            }

            _player.CheckPcMoveInputs();

            if (_player.SpeedFactor > 0.2f && _player.IsOnFloor())
            {
                _player.ChangeAnimMoveState("Walk");
            }

            if (Input.IsActionPressed("jump"))
            {
                _player.ChangeState("Jump");
            }

            if (!_player.CheckPcMoveInputs())
            {
                _player.ChangeState("Idle");
            }
        }

        public void Exit()
        {
            GD.Print("Saliendo de Walk");
        }
    }
}