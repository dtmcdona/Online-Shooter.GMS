///server_create(port)

var port = argument0;
var server = 0;
server = network_create_server_raw(network_socket_tcp, port, 20);
//keeps track of clients
clientmap = ds_map_create();
client_id_counter = 0;

//sent information is stored in this buffer
send_buffer = buffer_create(256, buffer_fixed, 1);

if(server < 0) show_error("Could no create server!", true);

return server;
