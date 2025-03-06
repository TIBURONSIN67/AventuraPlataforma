using Godot;
using System;
using BatteryRush.components.componentHealth;
using BatteryRush.Globals;

namespace BatteryRush.scenes.ui
{
    public partial class GameOver : Control
    {
        //Variables para el Game Over
        [Export] private PlayerHud _playerHud;
        [Export] private ComponentHealth _health;
        [Export] private Button _buttonRespawn;
        [Export] private Label _gameOverMessage;
        [Export] private Button _mainMenuButton;
        [Export] private Label _livesLabel;
        [Export] private CharacterBody3D _player;

        private float _respawnHealth;
        private PackedScene _mainMenuScene;
        private String _mainMenuScenePath = "res://scenes/menu.tscn";

        public override void _Ready()
        {
            _respawnHealth = (_health.GetMaxHealth()) / 1.5f;
            _health.OnDeath += _is_dead;
            _buttonRespawn.ButtonUp += Respawn;
            Visible = false;
            _mainMenuScene = GD.Load<PackedScene>(_mainMenuScenePath);
        }

        private void Respawn()
        {
            _player.GlobalPosition = PlayerStats.Instance.LastCheckpoint;
            Input.MouseMode = Input.MouseModeEnum.Captured;
            Visible = false;
            _health.Heal(_respawnHealth);  
            _playerHud.Visible = true;
        }

        private void _is_dead()
        {
            _playerHud.Visible = false;
            Input.MouseMode = Input.MouseModeEnum.Visible;
            Visible = true;
        }
    }
}

