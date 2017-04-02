///server_handle_disconnect(async_load[? "socket"]);
var socket_id = argument0;
//sending message_leave with info for disconnecting client
buffer_seek(send_buffer, buffer_seek_start, 0);
buffer_write(send_buffer, buffer_u8, MESSAGE_LEAVE)
buffer_write(send_buffer, buffer_u16, clientmap[? string(socket_id)].client_id);

with(clientmap[? string(socket_id)])
{
    instance_destroy();
}
ds_map_delete(clientmap, string(socket_id));

with(obj_serverClient)
{
    network_send_raw(self.socket_id, other.send_buffer, buffer_tell(other.send_buffer));
}
