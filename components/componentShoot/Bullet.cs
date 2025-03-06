using Godot;

public partial class BulletA : RigidBody3D
{
    [Export] public float BulletSpeed = 25.0f;
    [Export] public float LifeTime = 5.0f;
    [Export] private Timer timer;
    [Export] private HitBox componentHitBox;

    public override void _Ready()
    {
        timer = GetNode<Timer>("Timer");
        componentHitBox = GetNode<HitBox>("ComponentHitBox");

        timer.WaitTime = LifeTime;
        timer.OneShot = true;
        timer.Timeout += _OnTimerTimeout;
        timer.Start();
    }

    public void Shoot(Vector3 direccion, Vector3 pos)
    {
        GlobalPosition = pos;
        direccion = direccion.Normalized();
        LinearVelocity = direccion * BulletSpeed;
    }

    private void _OnTimerTimeout()
    {
        QueueFree();
    }

    public void SetSpeed(float speed)
    {
        BulletSpeed = speed;
    }

    public void SetDamage(float damage)
    {
        componentHitBox.SetDamage(damage);
    }

    public override void _ExitTree()
    {
        timer.Timeout -= _OnTimerTimeout;
    }
}