local blips = {
    {id = "hosp1", name = "Hospital", scale = 0.75, color = 2, sprite = 61, x = 357.43, y= -593.36, z= 28.79}, --
    {id = "cloth1", name = "Clothing", scale = 0.6, color = 3, sprite = 73, x = 425.236, y=-806.008, z=29.491},
    {id = "cloth2", name = "Clothing", scale = 0.6, color = 3, sprite = 73, x = -162.658, y=-303.397, z=39.733},
    {id = "cloth3", name = "Clothing", scale = 0.6, color = 3, sprite = 73, x = 75.950, y=-1392.891, z=29.376},
    {id = "cloth4", name = "Clothing", scale = 0.6, color = 3, sprite = 73, x = -822.194, y=-1074.134, z=11.328},
    {id = "cloth5", name = "Clothing", scale = 0.6, color = 3, sprite = 73, x = -1450.711, y=-236.83, z=49.809},
    {id = "cloth6", name = "Clothing", scale = 0.6, color = 3, sprite = 73, x = 4.254, y=6512.813, z=31.877},
    {id = "cloth7", name = "Clothing", scale = 0.6, color = 3, sprite = 73, x = 615.180, y=2762.933, z=44.088},
    {id = "cloth8", name = "Clothing", scale = 0.6, color = 3, sprite = 73, x = 1196.785, y=2709.558, z=38.222},
    {id = "cloth9", name = "Clothing", scale = 0.6, color = 3, sprite = 73, x = -3171.453, y=1043.857, z=20.863},
    {id = "cloth10", name = "Clothing", scale = 0.6, color = 3, sprite = 73, x = -1100.959, y=2710.211, z=19.107},
    {id = "cloth11", name = "Clothing", scale = 0.6, color = 3, sprite = 73, x = -1192.9453125, y=-772.62481689453, z=17.3254737854},
    {id = "cloth12", name = "Clothing", scale = 0.6, color = 3, sprite = 73, x = -707.33416748047, y=-155.07914733887, z=37.415187835693},

    {id = "cloth13", name = "Clothing", scale = 0.6, color = 3, sprite = 73, x = 1683.45667, y=4823.17725, z=42.1631294},
    {id = "cloth14", name = "Clothing", scale = 0.6, color = 3, sprite = 73, x = -712.215881, y=-155.352982, z=37.4151268},
    {id = "cloth15", name = "Clothing", scale = 0.6, color = 3, sprite = 73, x =121.76, y=-224.6, z=54.56},
    {id = "cloth16", name = "Clothing", scale = 0.6, color = 3, sprite = 73, x = -1207.5267333984, y=-1456.9530029297, z=4.3763856887817},

    {id = "bar1", name = "Bahama Mamas", sprite = 93, x = -1388.53430175781, y=-586.615295410156, z=29.2186660766602},

    {id = "pcenter", name = "Payments & Internet Center", scale = 1.3, sprite = 351, color = 17, x=-1081.8293457031, y=-248.12872314453, z=37.763294219971},
    {id = "jcenter", name = "Job Center", scale = 1.3, sprite = 351, color = 17, x=172.78, y=-26.89, z=68.35},

    {id = "fishingsales", name = "Fish Sales", scale = 0.7, color = 7, sprite = 304, x=-1038.4649658203, y=-1396.7390136719, z=5.5531921386719},
    {id = "comedy", name = "Comedy Club", scale = 0.7, color = 7, sprite = 102, x=-431.235299, y=259.939819, z=82.9778519},

    {id = "Imports", name = "Fast Lane Imports & Towing", scale = 0.7, color = 7, sprite = 326, x=-47.138111114502, y=-1680.5421142578, z=29.41027641296},

    {id = "courthouse", name = "Los Santos Courthouse", scale = 0.7, color = 5, sprite = 58, x=244.5550079345, y=-386.0076904298, z=45.402359008789315},
    {id = "lawyersoffice", name = "Lawyers Offices", scale = 0.7, color = 5, sprite = 58, x=245.91703796387, y=-347.61932373047, z=44.451446533203},

    {id = 'TaxiRank', name = 'Taxi Rank', scale = 0.7, color = 5, sprite = 56, x = -12.72, y = -143.3, z = 56.26},
    
    {id = 'qf', name = 'The Quick Fix', scale = 0.7, color = 8, sprite = 478, x = 968.03, y = -126.64, z = 74.37},

    {id = "di", name = "Driving Instructor", scale = 0.6, color = 44, sprite = 380, x = 983.83, y= -206.17, z= 71.07},
}


AddEventHandler("fxbase:playerSessionStarted", function()
    Citizen.CreateThread(function()
        for k,v in ipairs(blips) do
            FX.BlipManager.CreateBlip(v.id, v)
        end
    end)
end)


