using Godot;
using System.Collections.Generic;
using BatteryRush.Components.ComponentPlayer.ViewScene;
using BatteryRush.Globals;
using BatteryRush.components.componentPlayer.states;
using BatteryRush.Components.ComponentPlayer.States;

namespace BatteryRush.components.componentPlayer
{
    public partial class Player : CharacterBody3D
    {
        // Campos privados encapsulados con propiedades
        [Export] private AnimationTree _animationTree;
        [Export] private ViewTp _viewTp;
        [Export] private Control _virtualJoystick;
        [Export] private RayCast3D _rayCast;
        [Export] private CpuParticles3D _particlesTrail;
        [Export] private AudioStreamPlayer3D _landingSound;
        [Export] private float _coyoteTimeDuration = .3f;
        private Vector3 _inputKey;
        public Vector3 InputKey { get => _inputKey; set => _inputKey = value; }
        private Vector3 _movementVelocity;
        private Vector3 _appliedVelocity;
        private Vector3 _velocity;

        private readonly Dictionary<string, IState> _states = new Dictionary<string, IState>();
        private readonly Dictionary<string, string> _animationStates = new Dictionary<string, string>
        {
            { "Idle", "Idle" },
            { "Walk", "Walk" },
            { "Jump", "Jump" },
            { "Dead", "Dead" },
            { "Fall", "Fall" },
            { "NotDead", "NotDead" }
        };

        // Propiedades con `get` y `set`
        [Export] private Timer _coyoteTimer;
        public Timer CoyoteTimer { get => _coyoteTimer; set => _coyoteTimer = value; }
        [Export] private AudioStreamPlayer3D _walkAudio;
        public AudioStreamPlayer3D WalkAudio { get => _walkAudio; set => _walkAudio = value; }
        [Export] private Node3D _character;
        public Node3D Character { get => _character; set => _character = value; }
        private bool _jumpSingle;
        public bool JumpSingle { get => _jumpSingle; set => _jumpSingle = value; }
        private float _speedFactor;
        public float SpeedFactor { get => _speedFactor; set => _speedFactor = value; }
        private bool _canJump = true;
        public bool CanJump { get => _canJump; set => _canJump = value; }
        private bool _dead;
        public bool IsDead { get => _dead; private set => _dead = value; }

        private float _playerGravity;
        public float PlayerGravity { get => _playerGravity; set => _playerGravity = value; }
        private float _defaultGravity = 23f;
        public float DefaultGravity { get => _defaultGravity; set => _defaultGravity = value; }
        public float Gravity { get => _playerGravity; set => _playerGravity = Mathf.Max(0, value); }

        private bool _isMeleeAttack;
        public bool IsMeleeAttack { get => _isMeleeAttack; set => _isMeleeAttack = value; }

        [Export] private float _movementSpeed = 1500f;
        public float MovementSpeed { get => _movementSpeed; set => _movementSpeed = Mathf.Max(0, value); }

        [Export] private float _jumpStrength = 500f;
        public float JumpStrength { get => _jumpStrength; set => _jumpStrength = Mathf.Max(0, value);  }

        private string _currentState = "Idle";
        public string CurrentState
        {
            get => _currentState;
            private set
            {
                if (_currentState != value && _states.ContainsKey(value))
                {
                    _states[_currentState].Exit();
                    _currentState = value;
                    _states[_currentState].Enter();
                    ChangeAnimMoveState(value);
                }
            }
        }

        public override void _Ready()
        {
            Gravity = _defaultGravity;

            _states["Idle"] = new IdleState(this);
            _states["Walk"] = new WalkState(this);
            _states["Jump"] = new JumpState(this);
            _states["Fall"] = new FallState(this);
            CurrentState = "Idle";
        }

        public override void _Process(double delta)
        {
            Vector2 horizontalVelocity = new Vector2(Velocity.X, Velocity.Z); // Actualización de velocidad horizontal
            _speedFactor = horizontalVelocity.Length() / _movementSpeed / (float)delta;
        }

        public override void _PhysicsProcess(double delta)
        {
            _states[CurrentState].Update((float)delta);
            HandleControls((float)delta);
            HandleEffects((float)delta);
            _appliedVelocity = _velocity.Lerp(_movementVelocity, (float)delta * 10);
            
            Velocity = new Vector3(
                IsMeleeAttack ? _appliedVelocity.X * 0.95f : _appliedVelocity.X, 
                Velocity.Y, 
                IsMeleeAttack ? _appliedVelocity.Z * 0.95f : _appliedVelocity.Z
            );

            Velocity = new Vector3(Velocity.X, Velocity.Y - Gravity * (float)delta, Velocity.Z);
            MoveAndSlide();
        }

        public void ChangeAnimMoveState(string newState)
        {
            if (!_animationStates.TryGetValue(newState, out string targetIndex))
            {
                GD.Print($"No se encontró el estado: {newState} en el diccionario");
                return;
            }

            string transitionPath = targetIndex switch
            {
                "Jump" => "parameters/Jump/request",
                "Dead" or "NotDead" => "parameters/Transition2/transition_request",
                _ => "parameters/Transition/transition_request"
            };

            if (targetIndex == "Jump")
            {
                if (!(bool)_animationTree.Get("parameters/Jump/active"))
                {
                    _animationTree.Set(transitionPath, (int)AnimationNodeOneShot.OneShotRequest.Fire);
                }
            }
            else
            {
                string currentState = (string)_animationTree.Get(transitionPath.Replace("transition_request", "current_state"));
                if (currentState != targetIndex)
                {
                    _animationTree.Set(transitionPath, targetIndex);
                }
            }
        }

        private void HandleControls(float delta)
        {
            if (PlatformChecker.Instance.IsWindows()) 
            {
                HandlePcControls(delta);
            }
            else if (PlatformChecker.Instance.IsAndroid()) 
            {
                HandleAndroidControls(delta);
            }

            _inputKey = _inputKey.Length() > 1 ? _inputKey.Normalized() : _inputKey;
            _movementVelocity = _inputKey.Length() >= 0.5f ? _inputKey * _movementSpeed * delta : Vector3.Zero;
        }

        private void HandlePcControls(float delta)
        {
            if (IsDead)
            {
                _inputKey = Vector3.Zero;
                return;
            }

            _inputKey = Vector3.Zero;
            if (Input.IsActionPressed("forward")) _inputKey.Z = 1;
            if (Input.IsActionPressed("backward")) _inputKey.Z = -1;
            if (Input.IsActionPressed("left")) _inputKey.X = 1;
            if (Input.IsActionPressed("right")) _inputKey.X = -1;

            if (CheckPcMoveInputs())
            {
                Vector3 rotation = Rotation;
                _inputKey = _inputKey.Rotated(Vector3.Up, _viewTp.GlobalRotation.Y);
                rotation.Y = Mathf.LerpAngle(GlobalRotation.Y, Mathf.Atan2(_inputKey.X, _inputKey.Z), delta * 20);
                GlobalRotation = rotation;
            }
            else
            {
                _inputKey = Vector3.Zero;
            }
        }

        private void HandleAndroidControls(float delta)
        {
            GD.Print(delta);
        }

        public bool CheckPcMoveInputs() =>
            Input.IsActionPressed("left") ||
            Input.IsActionPressed("right") ||
            Input.IsActionPressed("forward") ||
            Input.IsActionPressed("backward");

        public void HandleEffects(float delta)
        {
            GD.Print(_speedFactor);
            _particlesTrail.Emitting = false;
            _walkAudio.StreamPaused = true;

            if (IsOnFloor() && _speedFactor > 0.05f)
            {
                if (_speedFactor > 0.2f)
                {
                    _walkAudio.StreamPaused = false;
                    _walkAudio.PitchScale = _speedFactor;
                }
                if (_speedFactor > 0.75f)
                {
                    _particlesTrail.Emitting = true;
                }
            }
        }

        public bool RaycastIsColliding() => _rayCast.IsColliding();
        
        public void ChangeState(string newState)
        {
            if (_currentState == newState || !_states.ContainsKey(newState))
            {
                return;
            }
    
            _states[_currentState].Exit();
            _currentState = newState;
            _states[_currentState].Enter();
            ChangeAnimMoveState(newState);
        }
        public void LandEffects()
        {
            _character.Scale = new Vector3(1.2f, 0.85f, 1.2f);
            _landingSound.Play();
            _coyoteTimer.Stop();
            _coyoteTimer.WaitTime = _coyoteTimeDuration;
            _jumpSingle = false;
            _canJump = true;
            _playerGravity = _defaultGravity; 
        }

    }
}
