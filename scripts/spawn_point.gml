///spawnPoint(obj)
obj = argument0
if(obj.hp <= 0)
{
    if(obj.teamBlue = 1)
    {
        if(!firstSpawn)
            deaths++;
        firstSpawn = false;
        obj.x = 144
        obj.y = 60
    }
    else
    {
        if(!firstSpawn)
            deaths++;
        firstSpawn = false;
        obj.x = 890
        obj.y = 360
    }
    obj.hp = 100;
    botMove = true;
}
