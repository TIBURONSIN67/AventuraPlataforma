using Godot;

public partial class ComponentShoot : Node3D
{
    [Signal]
    public delegate void ShootingEventHandler();

    [Export] public PackedScene BulletScene;
    private BulletA bulletA;

    [Export] private Timer timer;
    private bool canShoot = false;
    [Export] public float CooldownShoot = 0.1f; // Tiempo de enfriamiento entre disparos
    [Export] private Marker3D shootPoint;
    private bool currentTimer = false;
    [Export] public float BulletSpeed = 10f;
    [Export] public float Damage = 10.0f;


    public override void _Ready()
    {
        timer = GetNode<Timer>("Timer");
        shootPoint = GetNode<Marker3D>("Marker3D");

        timer.Timeout += _Timeout;
        timer.WaitTime = CooldownShoot; // Configura el tiempo de enfriamiento
    }

    public void InstantShoot(Vector3 direction)
    {
        EmitSignal(nameof(Shooting)); // Emit the signal
        bulletA = BulletScene.Instantiate<BulletA>(); // Instantiate the bullet
        GetTree().Root.AddChild(bulletA);
        bulletA.SetSpeed(BulletSpeed);
        bulletA.SetDamage(Damage);
        bulletA.Shoot(direction, shootPoint.GlobalPosition); // Call the public Shoot method
    }

    public void Shoot(Vector3 direction)
    {
        if (!currentTimer)
        {
            timer.Start();
            currentTimer = true;
        }

        if (canShoot)
        {
            // Solo permite disparar si el temporizador no está en ejecución
            EmitSignal(nameof(Shooting)); // Emit the signal
            bulletA = BulletScene.Instantiate<BulletA>(); // Instantiate the bullet
            GetTree().Root.AddChild(bulletA);
            bulletA.Shoot(direction, shootPoint.GlobalPosition); // Call the public Shoot method
            canShoot = false;
        }
    }

    public void StopShoot()
    {
        // Detiene el temporizador y reinicia la posibilidad de disparar
        timer.Stop();
        currentTimer = false;
    }

    private void _Timeout()
    {
        // Habilita el disparo nuevamente al finalizar el temporizador
        canShoot = true;
    }

    public void SetBulletSpeed(float speed)
    {
        BulletSpeed = speed;
    }

    public void SetDamage(float d)
    {
        Damage = d;
    }

    public void SetCooldownShoot(float c)
    {
        timer.WaitTime = c;
    }

    public override void _ExitTree()
    {
        timer.Timeout -= _Timeout;
    }
}