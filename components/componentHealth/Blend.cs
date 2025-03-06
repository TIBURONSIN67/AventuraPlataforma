using Godot;

namespace BatteryRush.components.componentHealth
{

    public partial class Blend : Node3D
    {
        [Export] private Timer _timer;

        [Export] public ComponentHealth Health;
        [Export] public float DamageAmount = 1f; // Daño por sangrado
        [Export] public float BleedInterval = 0.1f; // Intervalo de tiempo en segundos para el sangrado

        public override void _Ready()
        {
            _timer = GetNode<Timer>("Timer");

            _timer.WaitTime = BleedInterval; // Configura el tiempo de espera del timer
            _timer.Timeout += _OnTimerTimeout;
        }

        private void _OnTimerTimeout()
        {
            if (Health != null)
            {
                Health.TakeDamage(DamageAmount); // Aplica el daño al personaje
            }
        }

        public override void _ExitTree()
        {
            _timer.Timeout -= _OnTimerTimeout;
        }
    }
}