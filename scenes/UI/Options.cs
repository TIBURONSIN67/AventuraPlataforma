using Godot;

namespace BatteryRush.scenes.ui
{
    public partial class Options : Control
    {
        [Export] private HSlider _masterSlider;
        [Export] private HSlider _musicSlider;
        [Export] private HSlider _sfxSlider;

        // Almacena los índices de los buses de audio
        int _busMaster;
        int _busMusic;
        int _busSfx;

        public override void _Ready()
        {
            // Conectar cada slider a su función respectiva
            _masterSlider.ValueChanged += _OnMasterSliderChanged;
            _musicSlider.ValueChanged += _OnMusicSliderChanged;
            _sfxSlider.ValueChanged += _OnSfxSliderChanged;

            _busMaster = AudioServer.GetBusIndex("Master");
            _busMusic = AudioServer.GetBusIndex("Music");
            _busSfx = AudioServer.GetBusIndex("Sfx");

            // Configurar valores iniciales de los sliders
            SetSliders();
        }

        private void SetSliders()
        {
            if (_busMaster != -1)
            {
                float busVolumeDb = AudioServer.GetBusVolumeDb(_busMaster);
                GD.Print($"volumen Master: {busVolumeDb}");

                // Ajustar los valores en el slider
                _masterSlider.MinValue = -80;  // Ajusta el rango mínimo del slider
                _masterSlider.MaxValue = 0;    // Ajusta el rango máximo del slider
                _masterSlider.Value = busVolumeDb;
            }

            if (_busMusic != -1)
            {
                float busVolumeDb = AudioServer.GetBusVolumeDb(_busMusic);
                GD.Print($"volumen Music: {busVolumeDb}");

                _musicSlider.MinValue = -80;
                _musicSlider.MaxValue = 0;
                _musicSlider.Value = busVolumeDb;
            }

            if (_busSfx != -1)
            {
                float busVolumeDb = AudioServer.GetBusVolumeDb(_busSfx);
                GD.Print($"volumen SFX: {busVolumeDb}");

                _sfxSlider.MinValue = -80;
                _sfxSlider.MaxValue = 0;
                _sfxSlider.Value = busVolumeDb;
            }
        }

        // Funciones separadas para cada slider
        private void _OnMasterSliderChanged(double value)
        {
            if (_busMaster != -1)
            {
                // Establecer el volumen en dB directamente desde el slider
                AudioServer.SetBusVolumeDb(_busMaster, (float)value);
            }
        }

        private void _OnMusicSliderChanged(double value)
        {
            if (_busMusic != -1)
            {
                AudioServer.SetBusVolumeDb(_busMusic, (float)value);
            }
        }

        private void _OnSfxSliderChanged(double value)
        {
            if (_busSfx != -1)
            {
                AudioServer.SetBusVolumeDb(_busSfx, (float)value);
            }
        }

        public override void _ExitTree()
        {
            // Desconectar los eventos
            _masterSlider.ValueChanged -= _OnMasterSliderChanged;
            _musicSlider.ValueChanged -= _OnMusicSliderChanged;
            _sfxSlider.ValueChanged -= _OnSfxSliderChanged;
        }
    }

    // Métodos de extensión para convertir entre volumen lineal y dB
    public static class AudioExtensions
    {
        public static float LinearToDb(this double linear)
        {
            return Mathf.LinearToDb((float)linear);
        }

        public static double DbToLinear(this float db)
        {
            return Mathf.DbToLinear(db);
        }

        public static double DbToLinear(this double db)
        {
            return Mathf.DbToLinear((float)db);
        }

        public static float LinearToDb(this float linear)
        {
            return Mathf.LinearToDb(linear);
        }
    }
}
