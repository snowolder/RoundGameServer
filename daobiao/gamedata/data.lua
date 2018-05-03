return {
    grade2exp = {
        --等级, 经验
        [1] = 100,
        [2] = 230,
        [3] = 400,
        [4] = 700,
        [5] = 1000,
    },
    item = {
        [1001] = {
            sid = 1001,
            belong = "virturl",
            name = "道具名-虚拟金币",
            cost_amount = 1,
            max_amount = 99,
        },
        [10001] = {
            sid = 10001,
            belong = "other",
            name = "道具名-经验丹",
            cost_amount = 1,
            max_amount = 99,
        },
    },
    skill = {
        [1001] = {
            skill_id = 1001,
            skill_name = "万剑归一",
            belong = "positive",
            perform_id = 1001,
        },
        [1002] = {
            skill_id = 1001,
            skill_name = "强身",
            belong = "passive",
            skill_effect = {phy_attack="10", max_hp="100*lv"},
            skill_effect_ratio = {}
        },
    },
}
