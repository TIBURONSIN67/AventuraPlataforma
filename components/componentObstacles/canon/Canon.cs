using Godot;

public partial class Canon : Node3D
{
    [Export] private Marker3D direction;
    [Export] public ComponentShoot ComponentShoot;
    [Export] private AnimationPlayer animationPlayer;

    [Export] public float Coldown = 1f;
    [Export] public float Damage = 10.0f;
    private Vector3 dir;

    public override void _Ready()
    {
        direction = GetNode<Marker3D>("Direction");
        animationPlayer = GetNode<AnimationPlayer>("StaticBody3D/Model/cañon/AnimationPlayer");

        dir = GlobalPosition.DirectionTo(direction.GlobalPosition);
        animationPlayer.Play("KeyAction");
        ComponentShoot.SetDamage(Damage);
        animationPlayer.SpeedScale = Coldown;
    }

    public void Shoot()
    {
        ComponentShoot.InstantShoot(dir);
    }
}