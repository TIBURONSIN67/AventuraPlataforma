using Godot;
using BatteryRush.Globals;
using System;

namespace BatteryRush.components.componentHealth
{
    public partial class ComponentHealth : Node
    {
        [Export] private Node3D _parent;
        [Export] private float _maxHealth = 100f;
        [Export] private float _minHealth;
        [Export] private float _currentHealth = 100f;
        [Export] private TextureProgressBar _healthBar;

        [Signal] public delegate void OnHealthChangedEventHandler(float minHealth, float maxHeath, float newHealth);
        [Signal] public delegate void OnDeathEventHandler();

        public override void _Ready()
        {
            UpdateHealth();
        }
        

        private void UpdateHealth()
        {
            if (_healthBar != null)
            {
                _healthBar.Value = (_currentHealth / _maxHealth) * 100;
            }
            if (_parent.IsInGroup("Player"))
            {
                PlayerStats.Instance.Health = _currentHealth;
            }
            EmitSignal(SignalName.OnHealthChanged, _minHealth, _maxHealth, _currentHealth);
        }
        public void TakeDamage(float damage)
        {
            _currentHealth -= damage;
            _currentHealth = Math.Max(_currentHealth, _minHealth); // Evitar que baje de 0

            UpdateHealth();

            if (_currentHealth <= _minHealth)
            {
                if (_parent.IsInGroup("Player"))
                {
                    PlayerStats.Instance.IsDead = true;
                }
                EmitSignal(SignalName.OnDeath);
                GD.Print("La entidad ha muerto.");
            }
        }

        public void Heal(float amount)
        {
            _currentHealth += amount;
            _currentHealth = Math.Min(_currentHealth, _maxHealth); // Evitar que supere el máximo

            UpdateHealth();
            EmitSignal(SignalName.OnHealthChanged, _currentHealth);
        }

        public float GetMaxHealth()
        {
            return _maxHealth;
        }
    }
    
}