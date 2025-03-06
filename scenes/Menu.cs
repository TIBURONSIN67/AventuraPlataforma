using Godot;

namespace BatteryRush.scenes
{
    public partial class Menu : Control
    {
        [Export] private Button _playButton;
        [Export] private Button _exitButton;
        [Export] private PackedScene _mainScene;
        [Export] private AudioStreamPlayer _mainAudio;
        
        private AudioBusLayout _bus = (AudioBusLayout) GD.Load("res://Bus.tres");
        public override void _Ready()
        {
            AudioServer.SetBusLayout(_bus);
            _mainAudio.Play();
            _playButton.ButtonUp += Join;
            _exitButton.ButtonUp += Exit;
        }

        private void Join()
        {
            GetTree().ChangeSceneToPacked(_mainScene);
        }

        private void Exit()
        {
            GetTree().Quit();
        }
    }

}
