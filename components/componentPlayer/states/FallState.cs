using Godot;

namespace BatteryRush.components.componentPlayer.states
{
    public class FallState : IState
    {
        private readonly Player _player;
        public FallState(Player player)
        {
            _player = player;
        }

        public void Enter()
        {
            GD.Print("Entrando a Caer");
        }

        public void Update(float delta)
        {
            _player.CheckPcMoveInputs();
            _player.ChangeAnimMoveState("Fall");

            if (_player.CoyoteTimer.IsStopped() && _player.CanJump)
            {
                _player.CoyoteTimer.Start();
            }

            if (_player.IsOnFloor())
            {
                _player.LandEffects();
                _player.ChangeState("Idle");
                return;
            }

            if (Input.IsActionPressed("jump"))
            {
                if (_player.RaycastIsColliding())
                {
                    _player.LandEffects();
                    _player.ChangeState("Jump");
                }
                else if (_player.CanJump)
                {
                    _player.ChangeState("Jump");
                }
            }
        }

        public void Exit()
        {
            GD.Print("Saliendo de caer");
        }
    }
}