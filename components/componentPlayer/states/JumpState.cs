using System.Runtime.InteropServices;
using BatteryRush.components.componentPlayer;
using Godot;

namespace BatteryRush.Components.ComponentPlayer.States
{
    public class JumpState : IState
    {
        private readonly Player _player;

        public JumpState(Player player)
        {
            _player = player;
        }

        public void Enter()
        {
            GD.Print("Entrando a salto");
        }

        public void Update(float delta)
        {
            _player.CheckPcMoveInputs();
            
            if (!_player.JumpSingle && (_player.IsOnFloor() || _player.CanJump))
            {
                _player.WalkAudio.Play();
                _player.ChangeAnimMoveState("Jump");
                
                var velocity = _player.Velocity; 
                velocity.Y = _player.JumpStrength * delta; 
                _player.Velocity = velocity; 
                _player.Character.Scale = new Vector3(0.5f, 1.5f, 0.5f);
                _player.JumpSingle = true;
                _player.CanJump = false;
            }
            else if (!_player.IsOnFloor() && _player.Velocity.Y < 0 && _player.JumpSingle)
            {
                _player.CanJump = true;
                _player.ChangeState("Fall");
            }
            else if (_player.IsOnFloor() && _player.JumpSingle)
            {
                _player.ChangeState("Idle");
            }
        }

        public void Exit()
        {
            GD.Print("Saliendo de salto");
        }
    }
}