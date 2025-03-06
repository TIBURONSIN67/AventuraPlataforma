using BatteryRush.components.componentHealth;
using Godot;
using BatteryRush.Globals;

namespace BatteryRush.scenes.ui
{

    public partial class PlayerHud : Control
    {
        [Export] private Control _virtualJoystick;
        [Export] private ComponentHealth _health;
        [Export] private CharacterBody3D _entity;

        [Export] private HBoxContainer _hBoxContainer;
        [Export] private HBoxContainer _hBoxContainer2;
        [Export] private TouchScreenButton _jump;
        [Export] private TouchScreenButton _attackMelee;
        [Export] private TextureProgressBar _healthProgressBar;
        [Export] private Button _buttonPause;

        private bool _entityDead;
        private float _respawnHealth = 100.0f;

        public override void _Ready()
        {

            _buttonPause.ButtonDown += _ButtonPauseDown;
            _buttonPause.ButtonUp += _ButtonPauseUp;

            if (PlatformChecker.Instance.IsWindows())
            {
                GD.Print("configuración para windows establecida");
                _SetUi("desktop");
            }
            else if (PlatformChecker.Instance.IsAndroid())
            {
                GD.Print("Configuración para android establecida");
                _SetUi("mobile");
            }

            _health.OnDeath += _EntityDead;
            PlayerStats.Instance.LastCheckpoint = _entity.GlobalPosition;
        }

        public override void _Process(double delta)
        {
            if (Input.IsActionJustPressed("respawn"))
            {
                if (_entityDead && PlayerStats.Instance.Lives > 0)
                {
                    PlayerStats.Instance.Lives -= 1;
                    _entityDead = false;
                    _health.Heal(_respawnHealth);
                    _entity.GlobalPosition = PlayerStats.Instance.LastCheckpoint;
                    Input.MouseMode = Input.MouseModeEnum.Captured;
                }
            }
        }

        private void _EntityDead()
        {
            _entityDead = true;
        }

        private void _SetUi(string type)
        {
            switch (type)
            {
                case "mobile":
                    _ConfigureMobileUi();
                    break;
                case "desktop":
                    _ConfigureDesktopUi();
                    break;
            }
        }

        private void _ConfigureMobileUi()
        {
            _virtualJoystick.Visible = true;
            _jump.Visible = true;
            _attackMelee.Visible = true;
            _hBoxContainer.Visible = true;
            _hBoxContainer2.Visible = true;
        }

        private void _ConfigureDesktopUi()
        {
            _virtualJoystick.Visible = false;
            _jump.Visible = false;
            _attackMelee.Visible = false;
            _hBoxContainer.Visible = false;
            _hBoxContainer2.Visible = false;
        }

        private void _ButtonPauseUp()
        {
            Input.ActionRelease("Pause");
        }

        private void _ButtonPauseDown()
        {
            Input.ActionPress("Pause");
        }
    }
}