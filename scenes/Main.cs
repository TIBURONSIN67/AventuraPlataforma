using Godot;
using System;

namespace BatteryRush.scenes
{
    public partial class Main : Node3D
    {
        [Export]
        private AudioStreamPlayer _backgroundMusic;
        
        public override void _Ready()
        {
            GD.Print("VAR");
            _backgroundMusic.Play();
        }
    }
}
