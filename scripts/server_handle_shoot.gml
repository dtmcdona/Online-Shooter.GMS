///server_handle_shoot(shootdirection, clientObject)
var shootdirection = argument0;
var tempObject = argument1;
var hit = false;
var obj = noone;

var prevX = tempObject.x;
var prevY = tempObject.y;
var prog = 0;
var tox = prevX;
var toy = prevY;

with(tempObject)
{
    while(prog < SHOOT_RANGE)
    {
        tox = prevX + lengthdir_x(10, shootdirection);
        toy = prevY + lengthdir_y(10, shootdirection);
        obj = collision_line(prevX, prevY, tox, toy, obj_serverClient, true, true);
        if(instance_exists(obj))
        {
            //hit!
            hit = true;
            prog += 10;
            break;
        }
        prevX = tox;
        prevY = toy;
        prog += 10;
    }
    
    create_shootline(x, y, tox, toy, shootdirection);
    audio_play_sound(pistol,true,false);
}

//Hit something!
if(hit)
{
    kills = false
    if(obj.hp <= 25)
        kills = true
    obj.hp -= 25;
    buffer_seek(send_buffer, buffer_seek_start, 0);
    buffer_write(send_buffer, buffer_u8, MESSAGE_HIT);
    buffer_write(send_buffer, buffer_u16, tempObject.client_id);
    buffer_write(send_buffer, buffer_u16, obj.client_id);
    buffer_write(send_buffer, buffer_u16, shootdirection);
    buffer_write(send_buffer, buffer_u16, prog);
    buffer_write(send_buffer, buffer_s8, obj.hp);
    //send new kill to player
    buffer_write(send_buffer, buffer_bool,kills);
    
    with(obj_serverClient)
    {
        network_send_raw(self.socket_id, other.send_buffer, buffer_tell(other.send_buffer));     
    }
}
else
{
    buffer_seek(send_buffer, buffer_seek_start, 0);
    buffer_write(send_buffer, buffer_u8, MESSAGE_MISS)
    buffer_write(send_buffer, buffer_u16, tempObject.client_id)
    buffer_write(send_buffer, buffer_u16, shootdirection)
    buffer_write(send_buffer, buffer_u16, prog)
    
    with(obj_serverClient)
    {
        network_send_raw(self.socket_id, other.send_buffer, buffer_tell(other.send_buffer));     
    }
}
