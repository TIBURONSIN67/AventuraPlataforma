using Godot;

namespace BatteryRush.Globals
{
    public partial class PlayerStats : Node
    {
        public static PlayerStats Instance { get; private set; }

        // Player Stats
        public float Health { get; set; } = 100; // Initial health
        public int Lives { get; set; } = 5;
        public float MaxHealth { get; set; } = 100;
        public bool IsDead { get; set; } = false;
        public float Score { get; set; } = 0.0f;
        public float BatteriesCollected { get; set; } = 0; 

        // Other Player related data
        public Vector3 LastCheckpoint { get; set; } = Vector3.Zero; // Nullable Vector3 for checkpoints

        public override void _Ready()
        {
            Instance = this;
        }

        // Example methods
        public void ResetPlayerStats()
        {
            Health = MaxHealth;
            IsDead = false;
            Score = 0;
            BatteriesCollected = 0;
            LastCheckpoint = Vector3.Zero;
        }
    }
}