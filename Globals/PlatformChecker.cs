using Godot;

namespace BatteryRush.Globals
{
    public partial class PlatformChecker : Node
    {
        // Instancia estática para el singleton
        public static PlatformChecker Instance { get; private set; }

        private string _platformName;

        // Inicialización de la instancia cuando el nodo esté listo
        public override void _Ready()
        {
            Instance = this;
            _platformName = OS.GetName();
            GD.Print(_platformName);
        }

        // Métodos para verificar la plataforma
        public bool IsAndroid()
        {
            return _platformName == "Android";
        }

        public bool IsWindows()
        {
            return _platformName == "Windows";
        }
    }
}