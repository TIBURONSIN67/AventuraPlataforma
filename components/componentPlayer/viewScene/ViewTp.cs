using Godot;
using BatteryRush.components.componentHealth;
using BatteryRush.Globals;

namespace BatteryRush.Components.ComponentPlayer.ViewScene
{
    public partial class ViewTp : Node3D
    {
        // Grupo de propiedades exportadas en el editor
        [ExportGroup("Propiedades")]
        [Export] private CharacterBody3D _target; // El nodo objetivo al que la cámara seguirá

        // Grupo de propiedades para el zum
        [ExportGroup("Zoom")]
        [Export] private float _zoomMinimum = 15; // Zoom mínimo permitido
        [Export] private float _zoomMaximum = 1; // Zoom máximo permitido

        // Rotación de la cámara y variables relacionadas
        [ExportGroup("Rotación")]
        private Vector3 _cameraRotation; // Rotación actual de la cámara
        private float _zoom = 8; // Nivel de zoom actual
        private int _zoomDirection; // Dirección del zum (no se usa en el código actual, se podría usar para zum dinámico)

        // Nodos y vectores importantes
        [Export] private SpringArm3D _springArm; // El SpringArm que controla la distancia de la cámara
        private Vector2 _touchPos; // Posición del toque para dispositivos táctiles
        private Vector2 _mousePos; // Posición del mouse para escritorio

        [Export] private ComponentHealth _health; // Componente de salud del objetivo

        // Variables para el suavizado de la rotación
        private Vector2 _input = Vector2.Zero; // Entrada sin procesar para la rotación
        [Export] private float _touchSensY = 135.0f; // Sensibilidad táctil en el eje Y
        [Export] private float _touchSensX = 140.0f; // Sensibilidad táctil en el eje X

        [Export] private float _mouseSensY = 0.15f; // Sensibilidad del mouse en el eje Y
        [Export] private float _mouseSensX = 0.25f; // Sensibilidad del mouse en el eje X
        private Vector2 _normalizedTouch; // Posición táctil normalizada (no se usa en el código actual)

        private bool _isDead; // Indica si el jugador está muerto

        public override void _Ready()
        {
            // Inicializar la posición y rotación de la cámara
            Position = _target.Position;
            _cameraRotation = GlobalRotationDegrees; // Inicializar la rotación de la cámara a la rotación global inicial

            // Suscribirse a los eventos de muerte y cambio de salud del jugador
            _health.OnDeath += IsEntityDead;
            _health.OnHealthChanged += UpdatedHealth;

            // Capturar el mouse en Windows
            if (PlatformChecker.Instance.IsWindows())
            {
                Input.MouseMode = Input.MouseModeEnum.Captured; // Oculta y captura el cursor del mouse
            }
        }

        public override void _Input(InputEvent @event)
        {
            // Manejo de eventos táctiles (Android)
            if (PlatformChecker.Instance.IsAndroid())
            {
                if (@event is InputEventScreenDrag eventScreenDrag)
                {
                    Vector2 screenSize = GetViewport().GetVisibleRect().Size; // Obtener el tamaño de la pantalla

                    // Evitar división por cero si el tamaño de la pantalla es cero
                    if (screenSize.X < 0 || screenSize.Y < 0)                    
                    {
                        GD.Print("Advertencia: El tamaño de la pantalla es cero!");
                        _touchPos = Vector2.Zero;
                    }
                    else
                    {
                        // Normalizar la posición del toque
                        _touchPos.X = eventScreenDrag.Relative.X / screenSize.X;
                        _touchPos.Y = eventScreenDrag.Relative.Y / screenSize.Y;

                        // Escalar y limitar los valores normalizados (opcional)
                        _touchPos.X *= 2;
                        _touchPos.Y *= 2;
                        _touchPos.X = Mathf.Clamp(_touchPos.X, -1, 1);
                        _touchPos.Y = Mathf.Clamp(_touchPos.Y, -1, 1);

                        // ... usar _touchPos ...
                    }
                }
            }
            // Manejo de eventos de mouse (Windows)
            else if (PlatformChecker.Instance.IsWindows())
            {
                if (@event is InputEventMouseMotion mouseMotion)
                {
                    _mousePos.X = mouseMotion.Relative.X;
                    _mousePos.Y = mouseMotion.Relative.Y;

                    // ... usar _mousePos ...
                }
            }
        }

        public override void _PhysicsProcess(double delta)
        {
            if (_isDead) return; // No hacer nada si el jugador está muerto

            // Seguir al objetivo con suavizado (interpolación lineal)
            GlobalPosition = new Vector3(
                Mathf.Lerp(GlobalPosition.X, _target.GlobalPosition.X, (float)delta * 10),
                Mathf.Lerp(GlobalPosition.Y, _target.GlobalPosition.Y + 0.7f, (float)delta * 10), // Offset en Y
                Mathf.Lerp(GlobalPosition.Z, _target.GlobalPosition.Z, (float)delta * 10)
            );

            // Aplicar la rotación de la cámara
            GlobalRotationDegrees = _cameraRotation;

            // Suavizar el zoom
            _springArm.SpringLength = Mathf.Lerp(_springArm.SpringLength, _zoom, 5 * (float)delta);

            // Manejar la entrada según la plataforma
            if (PlatformChecker.Instance.IsWindows())
            {
                HandleInputWindows(delta);
            }
            else if (PlatformChecker.Instance.IsAndroid())
            {
                HandleInputAndroid(delta);
            }
        }

        // Manejo de entrada en Windows
        private void HandleInputWindows(double delta)
        {
            // Suavizar la rotación con el mouse
            _input.X -= _mousePos.X * _mouseSensX;
            _input.Y += _mousePos.Y * _mouseSensY;

            // Aplicar inercia a la rotación (suavizado)
            _cameraRotation.X = Mathf.Lerp(_cameraRotation.X, _input.Y, (float)delta * 20);
            _cameraRotation.Y = Mathf.Lerp(_cameraRotation.Y, _input.X, (float)delta * 20);

            // Limitar la rotación en el eje X
            _cameraRotation.X = Mathf.Clamp(_cameraRotation.X, -10, 90);

            // Resetear la posición del mouse para el próximo frame
            _mousePos = Vector2.Zero;
        }

        // Manejo de entrada en Android
        private void HandleInputAndroid(double delta)
        {
            // Suavizar la rotación con el toque
            _input.X -= _touchPos.X * _touchSensX;
            _input.Y += _touchPos.Y * _touchSensY;

            // Aplicar inercia a la rotación (suavizado)
            _cameraRotation.X = Mathf.Lerp(_cameraRotation.X, _input.Y, (float)delta * 20);
            _cameraRotation.Y = Mathf.Lerp(_cameraRotation.Y, _input.X, (float)delta * 20);

            // Limitar la rotación en el eje X
            _cameraRotation.X = Mathf.Clamp(_cameraRotation.X, -10, 90);

            // Resetear la posición del toque para el próximo frame
            _touchPos = Vector2.Zero;
        }

        // Se llama cuando el jugador muere
        private void IsEntityDead()
        {
            _isDead = true;
        }

        // Se llama cuando la salud del jugador cambia
        private void UpdatedHealth(float min, float max, float currentHealth)
        {
            // Revivir al jugador si su salud es mayor que el mínimo
            if (currentHealth > min)
            {
                _isDead = false;
            }
        }
    }
}