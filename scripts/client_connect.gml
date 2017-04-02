#define client_connect
///client_connect(ip,port,name)

var ip = argument0;
var port = argument1;
var name = argument2;

socket = network_create_socket(network_socket_tcp);
var connect = network_connect_raw(socket, ip, port);

send_buffer = buffer_create(256, buffer_fixed, 1);

clientmap = ds_map_create();

if(connect < 0)
    show_error("Could not connect to Server!", true);
        
buffer_seek(send_buffer, buffer_seek_start,0);
buffer_write(send_buffer, buffer_u8, MESSAGE_JOIN);
buffer_write(send_buffer, buffer_string, name);
///network send actually sends the buffer data
network_send_raw(socket, send_buffer, buffer_tell(send_buffer));
 
my_client_id = -1;

#define client_disconnect
///client_disconnect()

ds_map_destroy(clientmap);
network_destroy(socket);

#define client_handle_message
///client_handle_message(async_load[? "buffer"]);


var buffer = argument0;


while(true)
{
    var message_id = buffer_read(buffer, buffer_u8);
    
    switch(message_id)
    {
        case MESSAGE_GETID:
        
            my_client_id = buffer_read(buffer, buffer_u16);
        
        break;
        case MESSAGE_MOVE:
            //read output in same order it was sent
            var
            client = buffer_read(buffer, buffer_u16);
            xx = buffer_read(buffer, buffer_u16);
            yy = buffer_read(buffer, buffer_u16);
            //team blue 1 for true 0 for false
            teamBlue = buffer_read(buffer, buffer_u8);
            pointDir = buffer_read(buffer, buffer_u16);
            hp = buffer_read(buffer, buffer_s8);
            clientObject = client_get_object(client);
            
            clientObject.time = 0;
            clientObject.prevX = clientObject.x;
            clientObject.prevY = clientObject.y;
            clientObject.tox = xx;
            clientObject.toy = yy;
            clientObject.teamBlue = teamBlue;
            clientObject.pointDir = pointDir;
            clientObject.hp = hp;
            
            //with(obj_serverClient)
            //{
            //    if(client_id != client_id_current)
            //    {
            //        ///network send actually sends the buffer data
            //        network_send_raw(self.socket_id, other.send_buffer, buffer_tell(other.send_buffer));
            //    }
            //}
            
        break;
        
        case MESSAGE_JOIN:
            
            var client =  buffer_read(buffer,buffer_u16);
            var username = buffer_read(buffer,buffer_string);
            var clientObject = client_get_object(client);
            
            clientObject.name = username;
            
        break;
        
        case MESSAGE_LEAVE:
            
            var client = buffer_read(buffer, buffer_u16);
            tempObject = client_get_object(client);
            //destroy the player that left
            with(tempObject) instance_destroy();
            
        break;
        
        case MESSAGE_HIT:
        
            var clientshootid = buffer_read(buffer, buffer_u16);
            var clientshoot = client_get_object(clientshootid);
            var clientshotid = buffer_read(buffer, buffer_u16);
            var clientshot = client_get_object(clientshotid);
            var shootdirection = buffer_read(buffer, buffer_u16);
            var shootlength = buffer_read(buffer, buffer_u16);
            var hit_x = clamp(clientshoot.x + lengthdir_x(shootlength, shootdirection),clientshot.x,clientshot.x + 16);
            var hit_y = clamp(clientshoot.y + lengthdir_y(shootlength, shootdirection),clientshot.y,clientshot.y + 16);
            clientshot.hp = buffer_read(buffer, buffer_s8);
            var kills = buffer_read(buffer, buffer_bool);
            if(kills)
            {
                clientshoot.kills++;
            }
            
            create_shootline(clientshoot.x, clientshoot.y, hit_x, hit_y, shootdirection);
            
        break;
        
        case MESSAGE_MISS:
        
            var clientshootid = buffer_read(buffer, buffer_u16);
            var clientshoot = client_get_object(clientshootid);
            var shootdirection = buffer_read(buffer, buffer_u16);
            var shootlength = buffer_read(buffer, buffer_u16);
        
            create_shootline(clientshoot.x, clientshoot.y,clientshoot.x + lengthdir_x(shootlength,shootdirection),clientshoot.y + lengthdir_y(shootlength,shootdirection), shootdirection)
        break;
        
    }
    if(buffer_tell(buffer) == buffer_get_size(buffer))
    {
        break;
    }
    
}


#define client_send_movement
///client_send_movement()

buffer_seek(send_buffer, buffer_seek_start, 0);

buffer_write(send_buffer, buffer_u8, MESSAGE_MOVE);
buffer_write(send_buffer, buffer_u16, round(obj_Player.x));
buffer_write(send_buffer, buffer_u16, round(obj_Player.y));
buffer_write(send_buffer, buffer_u8, obj_Player.teamBlue);
buffer_write(send_buffer, buffer_u16, obj_Player.pointDir);
buffer_write(send_buffer, buffer_s8, obj_Player.hp)

network_send_raw(socket, send_buffer, buffer_tell(send_buffer));

#define client_get_object
///client_get_object(client_id)

var client_id = argument0;

if(client_id == my_client_id)
{
    if(!instance_exists(obj_Player))
        instance_create(0,0, obj_Player);
    
    return obj_Player.id;
}

//if we have received a message from this client before
if(ds_map_exists(clientmap, string(client_id)))
{
    return clientmap[? string(client_id)];
}
else//create new user if hes new
{
    var l = instance_create(0, 0, obj_OtherClient);
    clientmap[? string(client_id)] = l;
    return l;
}

#define client_send_shoot
///client_send_shoot(direction)

var dir = argument0;

buffer_seek(send_buffer, buffer_seek_start, 0)

buffer_write(send_buffer, buffer_u8, MESSAGE_SHOOT);
buffer_write(send_buffer, buffer_u16, dir);

network_send_raw(socket, send_buffer, buffer_tell(send_buffer));