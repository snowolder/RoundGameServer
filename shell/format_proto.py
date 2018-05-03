import commands
import os
import re

tmp_dict = {
    "client" : {
        "start" : "C2GSStart",
        "end"   : "C2GSEnd",
        "define": "C2GSDefines",
    },
    "server" : {
        "start" : "GS2CStart",
        "end"   : "GS2CEnd",
        "define": "GS2CDefines",
    },
}

def parse_defines(mark):
    start = 0
    result = {}
    mod = None
    with open("./proto/netdefines.lua", "r") as fp:
        for line in fp.readlines():
            if str.find(line, tmp_dict[mark]["start"]) != -1:
                start = 1
                continue
            elif str.find(line, tmp_dict[mark]["end"]) != -1:
                break
            if start != 1:
                continue

            m = re.match(r"(\w+)\.(\w+)", line)
            if m and len(m.groups()) == 2 and m.groups()[0] == tmp_dict[mark]["define"]:
                mod = m.groups()[1]
                result[mod] = {}
                continue
            m = re.match(r"(\w+) = (\d+)", str.strip(line))
            if m and len(m.groups()) == 2:
                result[mod][m.groups()[0]] = m.groups()[1]
    return result
            
def parse_proto(mark):
    result = {}
    starts = {
        "client"    :"C2GS",
        "server"    :"GS2C",
    }
    start = starts[mark]
    status, filelist = commands.getstatusoutput("ls ./proto/%s"%mark)
    for file in str.split(filelist, "\n"):
        path = "./proto/%s/%s"%(mark, file)
        proto = {}
        result[str.split(file, ".")[0]] = proto
        with open(path) as fp:
            for line in fp.readlines():
                if not line.startswith("message"):
                    continue
                m = re.match(r"(\w+) (\w+)", line)
                if m and len(m.groups()) == 2 and m.groups()[1].startswith(start):
                    proto[m.groups()[1]] = 0
    return result

def process_proto(mark):
    defines = parse_defines(mark)
    protos = parse_proto(mark)
    mod_delete = []
    for mod, pro_defines in defines.items():
        if not protos.has_key(mod):
            mod_delete.append(mod)
            continue
        delete = []
        for pro, val in pro_defines.items():
            if not protos[mod].has_key(pro):
                delete.append(pro)
        for pro in delete:
            del pro_defines[pro]
        for pro, val in protos[mod].items():
            if not pro_defines.has_key(pro):
                pro_defines[pro] = val
    for mod in mod_delete:
        del defines[mod]
    for mod, pro_defines in protos.items():
        if not defines.has_key(mod):
            defines[mod] = pro_defines

    result = set_proto_num(defines)
    write_to_file(mark, result)

    return defines

def set_proto_num(protos):
    mod2start = {}
    start2mod = {}
    prokeep = {}
    for mod, pro_defines in protos.items():
        prokeep[mod] = {}
        if len(pro_defines) > 0:
            for pro, val in pro_defines.items():
                if val != 0 and not mod2start.has_key(mod):
                    mod2start[mod] = int(val)/1000
                    start2mod[int(val)/1000] = mod
                if val != 0:
                    prokeep[mod][val] = 1
                
            
    start = 1
    for mod, pro_defines in protos.items():
        if mod2start.has_key(mod):
            pro_start = mod2start[mod]
        else:
            while start2mod.has_key(start):
                start = start + 1
            pro_start = start
            mod2start[mod] = pro_start
            start2mod[pro_start] = mod
        for pro, val in pro_defines.items():
            if val == 0:
                i = 0
                while prokeep[mod].has_key(pro_start*1000+i):
                    i = i + 1
                pro_defines[pro] = pro_start*1000+i
                prokeep[mod][pro_start*1000+i] = 1
        
    return protos

def write_to_file(mark, defines):
    starts = []
    ends = []
    start_flag, end_flag = 0, 0
    with open("./proto/netdefines.lua", "r") as fp:
        for line in fp.readlines():
            if start_flag == 0:
                starts.append(line)
            if str.find(line, tmp_dict[mark]["start"]) != -1:
                start_flag = 1
            elif str.find(line, tmp_dict[mark]["end"]) != -1:
                end_flag = 1
            if end_flag == 1:
                ends.append(line)

    middle = []
    start2mod = {}
    for mod, pro_defines in defines.items():
        for pro, val in pro_defines.items():
            if val != 0:
                start2mod[int(val)/1000] = mod
    lkey = sorted(start2mod.keys())
    for i in lkey:
        mod = start2mod[i]
        conlist = [tmp_dict[mark]["define"] + "." + mod + " = {"]
        lproto = sorted(defines[mod].keys(), lambda x, y: defines[mod][x]<defines[mod][y])
        for pro in lproto:
            conlist.append("    "+pro + " = " + str(defines[mod][pro]) + ",")
        conlist.append("}\n")
        middle.append("\n".join(conlist))

    content = "".join(starts) + "\n".join(middle) + "".join(ends)
    fp = open("./proto/netdefines.lua", "w+")
    fp.write(content)
    fp.flush()
    fp.close()


if __name__ == "__main__":
    process_proto("client")
    process_proto("server")
