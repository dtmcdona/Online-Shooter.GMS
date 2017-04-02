///server_handle_message(async_load[? "id"], async_load[? "buffer"]);

var socket_id = argument0;
var buffer = argument1;
var clientObject = clientmap[? string(socket_id)];
var client_id_current = clientObject.client_id;

while(true)
{
    var message_id = buffer_read(buffer, buffer_u8);
    
    switch(message_id)
    {
         
        case MESSAGE_MOVE:
        
            var xx = buffer_read(buffer, buffer_u16);
            var yy = buffer_read(buffer, buffer_u16);
            //team blue 1 for true 0 for false
            var teamBlue = buffer_read(buffer, buffer_u8);
            var pointDir = buffer_read(buffer, buffer_u16);
            hp = buffer_read(buffer, buffer_s8);
            
            clientObject.x = xx;
            clientObject.y = yy;
            clientObject.pointDir = pointDir;
            clientObject.hp = hp
            
            buffer_seek(send_buffer, buffer_seek_start, 0);
            buffer_write(send_buffer, buffer_u8, MESSAGE_MOVE);
            buffer_write(send_buffer, buffer_u16, client_id_current);
            buffer_write(send_buffer, buffer_u16, xx);
            buffer_write(send_buffer, buffer_u16, yy);
            buffer_write(send_buffer, buffer_u8, teamBlue);
            buffer_write(send_buffer, buffer_u16, pointDir);
            buffer_write(send_buffer, buffer_s8, hp)
            
            with(obj_serverClient)
            {
                if(client_id != client_id_current)
                {
                    ///network send actually sends the buffer data
                    network_send_raw(self.socket_id, other.send_buffer, buffer_tell(other.send_buffer));
                }
            }
            
        break;
        ///Message sent only when joining
        case MESSAGE_JOIN:
            
            username = buffer_read(buffer, buffer_string);
            clientObject.name = username;
            
            buffer_seek(send_buffer, buffer_seek_start, 0);
            buffer_write(send_buffer, buffer_u8, MESSAGE_JOIN);
            buffer_write(send_buffer, buffer_u16, client_id_current);
            buffer_write(send_buffer, buffer_string, username);
            
            //Sending the new username to all other clients
            with(obj_serverClient)
            {
                if(client_id != client_id_current)
                {
                    network_send_raw(self.socket_id, other.send_buffer, buffer_tell(other.send_buffer));
                }
            }
            ///New client recieves all other names of users
            with(obj_serverClient)
            {
                if(client_id != client_id_current)
                {
                    buffer_seek(other.send_buffer, buffer_seek_start, 0);
                    buffer_write(other.send_buffer, buffer_u8, MESSAGE_JOIN);
                    buffer_write(other.send_buffer, buffer_u16, client_id);
                    buffer_write(other.send_buffer, buffer_string, name);
                    //use socket_id of the server
                    network_send_raw(socket_id, other.send_buffer, buffer_tell(other.send_buffer));
                }
            }
        break;
        case MESSAGE_SHOOT:
        
            var shootdirection = buffer_read(buffer, buffer_u16);
            
            server_handle_shoot(shootdirection, clientObject);
        
        break;
        
    }
    if(buffer_tell(buffer) == buffer_get_size(buffer))
    {
        break;
    }
    
}

