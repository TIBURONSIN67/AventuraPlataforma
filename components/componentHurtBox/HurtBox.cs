using BatteryRush.components.componentHealth;
using Godot;

public partial class HurtBox : Node3D
{
    [Export] private ComponentHealth health;
    [Export] private AudioStreamPlayer3D hurtAudio;
    [Export] private Node3D character;

    private bool isEntityDead = false;

    public override void _Ready()
    {
        if (health != null) // Check for null to avoid errors
        {
            health.OnDeath += _IsDead;
            health.OnHealthChanged += _UpdatedHealth;
        }
        else
        {
            GD.Print("Health component not assigned to HurtBox on ", GetParent().Name);
        }
    }

    public override void _Process(double delta)
    {
        if (character != null)
        {
            character.Scale = character.Scale.Lerp(new Vector3(1, 1, 1), (float)(delta * 6));
        }
    }

    private void _UpdatedHealth(float currentHealth, float minHealth, float maxHealth)
    {
        if (currentHealth > minHealth)
        {
            isEntityDead = false;
        }
    }

    public void TakeDamage(float damage)
    {
        if (health != null && !isEntityDead)
        {
            health.TakeDamage(damage);

            if (hurtAudio != null)
            {
                hurtAudio.Play();
            }
            else
            {
                GD.Print("Agregue un Audio stream player porfabor ", GetParent().Name);
            }

            if (character != null)
            {
                character.Scale = new Vector3(0.95f, 0.9f, 0.95f); // Use f suffix for float literals
            }
        }
    }

    private void _IsDead()
    {
        isEntityDead = true;
    }
}