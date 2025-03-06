using BatteryRush.Globals;
using Godot;

namespace BatteryRush.scenes.ui
{

    public partial class PauseMenu : Control
    {
        [Export] private Button _buttonResume;
        [Export] private Button _buttonExit;
        [Export] private Button _buttonOptions;
        [Export] private Options _options;
        [Export] private Button _backButton;

        private bool _isPaused;
        private bool _isDead;

        public override void _Ready()
        {

            _buttonResume.ButtonUp += _OnButtonResumePressed;
            _buttonExit.ButtonUp += _OnButtonExitPressed;
            _buttonOptions.ButtonUp += _OnButtonOptionsPressed;
            _backButton.ButtonUp += _OnBackButtonBackPressed;

            _options.Visible = false;
            _backButton.Visible = false;
            Visible = false;

        }

        public override void _Process(double delta)
        {
            _isDead = PlayerStats.Instance.IsDead;

            if (Input.IsActionJustPressed("pause") && !_isDead)
            {
                if (!_isPaused)
                {
                    GetTree().Paused = true;
                    Visible = true;
                    _isPaused = true;
                    Input.MouseMode = Input.MouseModeEnum.Visible;
                }
                else
                {
                    _isPaused = false;
                    GetTree().Paused = false;
                    Visible = false;
                    Input.MouseMode = Input.MouseModeEnum.Captured;
                }
            }
        }

        private void _OnButtonResumePressed()
        {
            GetTree().Paused = false;
            Visible = false;
            Input.MouseMode = Input.MouseModeEnum.Captured;
        }

        private void _OnButtonExitPressed()
        {
            GetTree().Quit();
        }

        private void _OnButtonOptionsPressed()
        {
            _options.Visible = true;
            _backButton.Visible = true;
        }

        private void _OnBackButtonBackPressed()
        {
            GD.Print("menu");
            _options.Visible = false;
            _backButton.Visible = false;
        }

        public override void _ExitTree()
        {
            _buttonResume.ButtonUp -= _OnButtonResumePressed;
            _buttonExit.ButtonUp -= _OnButtonExitPressed;
            _buttonOptions.ButtonUp -= _OnButtonOptionsPressed;
            _backButton.ButtonUp -= _OnBackButtonBackPressed;

        }
    }
}