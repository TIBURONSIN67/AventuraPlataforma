using Godot;

public partial class HitBox : Node3D
{
    [Export] private CollisionShape3D collision;
    [Export] private Area3D hitArea;
    [Export] private Timer timer;
    [Export] public bool IsShoot = false;
    [Export] public float Damage = 30.0f;
    [Export] public float WaitTime = 0.5f;
    [Export] private CpuParticles3D particle;

    private HurtBox hurtBox;
    private bool isActive = false; // Indica si el HitBox está activo
    private bool isTimerRunning = false; // Indica si el temporizador está en marcha

    public override void _Ready()
    {
        hitArea.AreaEntered += _OnAreaEntered;
        timer.Timeout += _OnTimerTimeout;
        _ResetHitbox();

        if (IsShoot)
        {
            ActivateHit();
        }
    }

    // Activar el HitBox y comenzar el temporizador
    public void ActivateHit()
    {
        if (!isTimerRunning)
        {
            isActive = true;
            isTimerRunning = true;
            collision.Disabled = false; // Activar la colisión
            if (!IsShoot)
            {
                timer.Start(WaitTime);
            }
        }
    }

    // Desactivar el HitBox manualmente
    public void DeactivateHit()
    {
        _ResetHitbox();
        timer.Stop();
        isTimerRunning = false;
    }

    // Resetear el estado del HitBox
    private void _ResetHitbox()
    {
        isActive = false;
        collision.Disabled = true;
        hurtBox = null; // Limpiar referencias de HurtBox
    }

    // Evento llamado al terminar el temporizador
    private void _OnTimerTimeout()
    {
        isTimerRunning = false;
        if (hurtBox != null)
        {
            hurtBox.TakeDamage(Damage);
            particle.GlobalPosition = hurtBox.GlobalPosition;
            particle.Emitting = true;
            GD.Print("Daño aplicado: ", Damage);
        }
        _ResetHitbox();
    }

    // Detectar cuando un área entra en el HitBox
    private void _OnAreaEntered(Area3D area)
    {
        // Verificar si el área es un HurtBox válido
        if (area.GetParent() is HurtBox hb) // Use pattern matching for a cleaner cast
        {
            hurtBox = hb;
            if (IsShoot)
            {
                hurtBox.TakeDamage(Damage);
                particle.GlobalPosition = hurtBox.GlobalPosition;
                particle.Emitting = true;
            }
        }
    }

    public void SetDamage(float d)
    {
        Damage = d;
    }

    public override void _ExitTree()
    {
        hitArea.AreaEntered -= _OnAreaEntered;
        timer.Timeout -= _OnTimerTimeout;
    }
}