

/*var testFuncs = {}
var Events = {}

Events.Subscribe = function(name, func) {
    testFuncs[name] = function(...Args) {
        return func(...Args)
    }
}
Events.Call = function(event_name, ...Args) {
    console.log("Event Call", event_name, Args)
}*/




const hBar = document.getElementById("health-bar-container"),
    bar = document.getElementById("health-bar"),
    hit = document.getElementById("hit-health");

var CurrentHealth = null;

Events.Subscribe("UpdateUIHealth", function(max_health, new_health) {
    if (CurrentHealth == null) {
        CurrentHealth = max_health;
    }
    hBar.classList.remove("hidden");

    if (new_health < 0) {
        new_health = 0;
    }

    var barWidth = (new_health / max_health) * 100 + "%";
    //console.log(barWidth);

    if (CurrentHealth > 0 && CurrentHealth - new_health > 0) {
        let hitWidth = ((CurrentHealth - new_health) / max_health) * 100 + "%";
        //console.log(hitWidth);
    
        hit.style.width = hitWidth;
    }

    setTimeout(function(){
        hit.style.width = "0";
        bar.style.width = barWidth;
    }, 300);

    CurrentHealth = new_health;
})

Events.Subscribe("HideUIHealth", function() {
    hBar.classList.add("hidden");
    CurrentHealth = null;
})


const hBar_vehicle = document.getElementById("health-bar-container-vehicle"),
    bar_vehicle = document.getElementById("health-bar-vehicle"),
    hit_vehicle = document.getElementById("hit-health-vehicle");

var CurrentHealth_vehicle = null;

Events.Subscribe("UpdateUIHealthVehicle", function(max_health, new_health) {
    if (CurrentHealth_vehicle == null) {
        CurrentHealth_vehicle = max_health;
    }
    hBar_vehicle.classList.remove("hidden");

    if (new_health < 0) {
        new_health = 0;
    }

    var barWidth = (new_health / max_health) * 100 + "%";

    if (CurrentHealth_vehicle > 0 && CurrentHealth_vehicle - new_health > 0) {
        let hitWidth = ((CurrentHealth_vehicle - new_health) / max_health) * 100 + "%";
    
        hit_vehicle.style.width = hitWidth;
    }

    setTimeout(function(){
        hit_vehicle.style.width = "0";
        bar_vehicle.style.width = barWidth;
    }, 300);

    CurrentHealth_vehicle = new_health;
})

Events.Subscribe("HideUIHealthVehicle", function() {
    hBar_vehicle.classList.add("hidden");
    CurrentHealth_vehicle = null;
})


const money_container = document.getElementById("money_container"),
    bank_money_container = document.getElementById("bank_money_container");

const money_capsule = document.getElementById("money_capsule"),
    bank_money_capsule = document.getElementById("bank_money_capsule");

Events.Subscribe("SetUIMoney", function(new_money) {
    money_container.classList.remove("hidden");

    money_capsule.innerText = new_money;
})

Events.Subscribe("SetUIBankMoney", function(new_money) {
    bank_money_container.classList.remove("hidden");

    bank_money_capsule.innerText = new_money;
})

Events.Subscribe("HideUIMoney", function() {
    money_container.classList.add("hidden");
})

Events.Subscribe("HideUIBankMoney", function() {
    bank_money_container.classList.add("hidden");
})




let levels_container
let levels_bar_bg
let levels_bar
let levels_text
let bar_percentage = 10

let bar_update_last = new Date().getTime();
let bar_update_anim_time = 0
let bar_update_old_old_width = 0
let bar_update_target_width = 0

let lvls_showed = false
let waiting_hide_timeout

Events.Subscribe("EnableOnlineLevels", function() {
    levels_container = document.createElement("div")
    levels_container.classList.add("lvls_container")
    levels_container.id = "lvls_container"

    levels_bar_bg = document.createElement("div")
    levels_bar_bg.classList.add("lvls_bar_bg")

    levels_bar = document.createElement("div")
    levels_bar.classList.add("lvls_bar")

    levels_text = document.createElement("div")
    levels_text.classList.add("lvls_text")

    levels_bar_bg.appendChild(levels_bar)

    levels_container.appendChild(levels_bar_bg)

    levels_container.appendChild(levels_text)

    document.body.appendChild(levels_container)

    /*tab_levels = document.createElement("div")
    tab_levels.classList.add("tab_item")
    tab_levels.innerText = "Level"

    levels_container.appendChild(tab_levels)*/
})

Events.Subscribe("SetBarPercentage", function(new_perc) {
    if (levels_bar) {
        if (!lvls_showed) {
            lvls_showed = true
            levels_container.classList.remove("lvls_hide_anim")
            levels_container.classList.add("lvls_show_anim")
        }

        levels_bar.classList.remove("lvlbar_up_anim")
        levels_bar.classList.remove("lvlbar_down_anim")

        let curTime = new Date().getTime();
        let old_bar_percentage = bar_percentage

        // delta | bar_update_anim_time    | bar_update_last
        //       | bar_update_target_width - bar_update_old_old_width | bar_update_old_old_width
        if (curTime - bar_update_last > 0 && curTime - bar_update_last < bar_update_anim_time) {
            old_bar_percentage = ((curTime - bar_update_last) * (bar_update_target_width - bar_update_old_old_width) / bar_update_anim_time) + bar_update_old_old_width
            //console.log(old_bar_percentage)
        }
        
        levels_bar.style.setProperty('--bar-target-width', new_perc + "%");
        levels_bar.style.setProperty('--bar-target-width-old', old_bar_percentage + "%")
        levels_bar.style.setProperty('--won-blur-px', Math.floor(Math.abs(new_perc - old_bar_percentage) * 7 / 10));
        levels_bar.style.setProperty('--won-spread-px', Math.floor(Math.abs(new_perc - old_bar_percentage) / 10));
        levels_bar.style.setProperty('--bar-anim-time', Math.floor(Math.abs(new_perc - old_bar_percentage) * 20) + "ms");
        levels_bar.offsetHeight;

        bar_update_last = new Date().getTime()
        bar_update_anim_time = Math.floor(Math.abs(new_perc - old_bar_percentage) * 20)
        bar_update_old_old_width = old_bar_percentage
        bar_update_target_width = new_perc

        //console.log(new_perc, bar_update_anim_time)

        if (new_perc <= old_bar_percentage) {
            //levels_bar.style.width = new_perc + "%"
            levels_bar.classList.add("lvlbar_down_anim")
        } else {
            levels_bar.classList.add("lvlbar_up_anim")
        }
        bar_percentage = new_perc

        if (waiting_hide_timeout) {
            clearTimeout(waiting_hide_timeout)
        }
        waiting_hide_timeout = setTimeout(function() {
            waiting_hide_timeout = null
            levels_container.classList.remove("lvls_show_anim")
            levels_container.classList.add("lvls_hide_anim")
            lvls_showed = false
        }, 10000)
    }
})

Events.Subscribe("SetLvlText", function(text) {
    if (levels_text) {
        levels_text.innerText = text
    }
})

//testFuncs.SetUIMoney("353$")

/*testFuncs.EnableOnlineLevels()
testFuncs.SetBarPercentage(0);
for (let i = 1; i < 11; i++) {
    setTimeout(function() {
        if (bar_percentage <= 95) {
            testFuncs.SetBarPercentage((i*5) % 100);
        } else {
            testFuncs.SetBarPercentage(0);
        }
    }, 400*i)
}
testFuncs.SetBarPercentage(0);
testFuncs.SetLvlText("200")*/

//testFuncs.UpdateUIHealth(2000, 500);
//testFuncs.UpdateUIHealthVehicle(2000, 500);