////create_shootline(x0, y0, x1, y1, direction)
var line = instance_create(0, 0, obj_shootLine);
line.x0 = argument0;
line.y0 = argument1;
line.x1 = argument2;
line.y1 = argument3;
line.image_angle = argument4+90;
if(collision_circle(argument0,argument1,12,obj_Player,false,false))
{
    with(obj_Player) shooting = true;
}
else if(object_exists(obj_OtherClient))
{
    if(collision_circle(argument0,argument1,12,obj_OtherClient,false,false))
        with(obj_OtherClient) shooting = true;
}
