#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import BigWorld
import threading
import time 
import json
import SoundGroups
from Avatar import PlayerAvatar, Avatar
from gui.battle_control import g_sessionProvider
from gui.battle_control.controllers.consumables.ammo_ctrl import AmmoController
from constants import PREBATTLE_TYPE
from messenger import MessengerEntry
from messenger.m_constants import BATTLE_CHANNEL
from messenger.ext.channel_num_gen import getClientID4Prebattle
from messenger.ext.channel_num_gen import getClientID4BattleChannel
from Account import Account
from gui import SystemMessages
from gui.mods.modsListApi import g_modsListApi
from gui.Scaleform.framework.entities.abstract.AbstractWindowView import AbstractWindowView
from gui.Scaleform.framework import g_entitiesFactories, ViewSettings 
from gui.Scaleform.framework import ViewTypes, ScopeTemplates
from gui.app_loader import g_appLoader

_VER_MOD = "1.5"
_VER_GAME_TEST = "0.9.15.1 Common Test"
_VER_GAME = "0.9.15.1"

def isBattleChat():
    squadChannelClientID = getClientID4Prebattle(PREBATTLE_TYPE.SQUAD)
    teamChannelClientID = getClientID4BattleChannel(BATTLE_CHANNEL.TEAM.name)
    commonChannelClientID = getClientID4BattleChannel(BATTLE_CHANNEL.COMMON.name)
    team = MessengerEntry.g_instance.gui.channelsCtrl.getController(teamChannelClientID)
    squad = MessengerEntry.g_instance.gui.channelsCtrl.getController(squadChannelClientID)
    common = MessengerEntry.g_instance.gui.channelsCtrl.getController(commonChannelClientID)	
    return {'team': team, 'common': common,'squad': squad}

def isValidate(array):
    for i in range(len(array) - 1):
        if (array[i] <= array[i + 1]) or not (0 < array[i] < 100) or not (0 < array[i + 1] < 100):
            return False;
    return True;

class SaveShells:
    def __init__(self):
        def openJsons(verGame):
            with open("./res_mods/configs/mod_save_shells/config.json") as f:
                self.json_config = json.load(f)
            with open("./res_mods/configs/mod_save_shells/vehicleNames.json") as fv:
                self.json_config_vehicle = json.load(fv)
            if self.json_config["enabled"]:
                self.enable = True
        self.numberShellsAll = 0
        self.numberShellsCurrent = 0
        self.enable = False
        self.isWarning = False
        self.ammoCtrl = None
        self._onShellsUpdated = None
        self.isHangar = False
        self.isSopping = True
        self.numberArrayPercent = 0;
        self.maxShellsInClip = 0
        self.isClip = False
        self.shotsInClip = 0
        self.isClipMessage = True
        self.checkClip = 0
        try:
            openJsons(_VER_GAME_TEST)
        except Exception:
            openJsons(_VER_GAME)

    def getPercent(self):
        def isEnabled(enabled = None, isVehicle = False, isLevels = False):
            if isVehicle:
                return self.json_config_vehicle["vehicleNames"][g_sessionProvider.getArenaDP().getVehicleInfo(BigWorld.player().playerVehicleID).vehicleType.iconName]["enabled"]
            elif isLevels:
                return self.json_config["notifications"][enabled][str(g_sessionProvider.getArenaDP().getVehicleInfo(BigWorld.player().playerVehicleID).vehicleType.level)]["enabled"]
            else:
                return self.json_config["notifications"][enabled][g_sessionProvider.getArenaDP().getVehicleInfo(BigWorld.player().playerVehicleID).vehicleType.getClassName()]["enabled"]
        def percent(percent = None, isVehicle = False, isLevels = False):
            if isVehicle:
                return self.json_config_vehicle["vehicleNames"][g_sessionProvider.getArenaDP().getVehicleInfo(BigWorld.player().playerVehicleID).vehicleType.iconName]["percent"] 
            elif isLevels:
                return self.json_config["notifications"][percent][str(g_sessionProvider.getArenaDP().getVehicleInfo(BigWorld.player().playerVehicleID).vehicleType.level)]["percent"]
            else:
                return self.json_config["notifications"][percent][g_sessionProvider.getArenaDP().getVehicleInfo(BigWorld.player().playerVehicleID).vehicleType.getClassName()]["percent"]
        if isEnabled(isVehicle = True):
            return percent(isVehicle = True)
        elif isEnabled("levels", isLevels = True):
            return percent("levels", isLevels = True)
        elif isEnabled("classNames"):
            return percent("classNames")
        else:
            return self.json_config["default_percent"]

    def checkShells(self):
        def replaces(string):
            try:
                return string.replace("{{shells-percent}}", str(self.getPercent()[self.numberArrayPercent])).replace("{{current-shells}}", str(self.numberShellsCurrent)).replace("{{current-shells-clip}}", str(self.shotsInClip)).replace("{{shells-percent-clip}}", str(self.json_config["autoReload"]["saveInOneClip"]["percent"])).encode('utf8')
            except IndexError:
                pass
        def myMessage():
            MessengerEntry.g_instance.gui.addClientMessage(replaces(self.json_config["notifications"]["texts"]["my"]))
        if self.enable:
            if self.isClip:
                if self.json_config["autoReload"]["saveInOneClip"]["enabled"]:
                    if (self.maxShellsInClip != self.shotsInClip) and (self.shotsInClip != 0):
                        if self.json_config["autoReload"]["saveInOneClip"]["percent"] < 100 and self.json_config["autoReload"]["saveInOneClip"]["percent"] > 0:
                            if int(self.maxShellsInClip / 100.0 * self.json_config["autoReload"]["saveInOneClip"]["percent"]) >= self.shotsInClip:
                                if self.shotsInClip >= self.checkClip:
                                    MessengerEntry.g_instance.gui.addClientMessage(replaces(self.json_config["autoReload"]["saveInOneClip"]["text"]));
                                    if self.json_config["autoReload"]["saveInOneClip"]["sound"]["enabled"]:
                                        SoundGroups.g_instance.playSound2D(self.json_config["autoReload"]["saveInOneClip"]["sound"]["soundName"].encode('utf8'))
                if self.json_config["autoReload"]["saveInClip"]["enabled"]:
                    if self.maxShellsInClip == self.shotsInClip:
                        self.isClipMessage = True
                    if self.isClipMessage:
                        if self.maxShellsInClip > g_sessionProvider.shared.ammo.getCurrentShells()[0]:
                            MessengerEntry.g_instance.gui.addClientMessage(replaces(self.json_config["autoReload"]["saveInClip"]["text"]));
                            self.isClipMessage = False
                            if self.json_config["autoReload"]["saveInClip"]["sound"]["enabled"]:
                                SoundGroups.g_instance.playSound2D(self.json_config["autoReload"]["saveInClip"]["sound"]["soundName"].encode('utf8'))
            if not self.isWarning:
                if isValidate(self.getPercent()):
                    if self.numberShellsAll / 100.0 * self.getPercent()[self.numberArrayPercent] >= self.numberShellsCurrent:
                        if self.json_config["notifications"]["team"]:
                            isBattleChat()["team"].sendMessage(replaces(self.json_config["notifications"]["texts"]["team"]))
                        elif self.json_config["notifications"]["squad"]:
                            if isBattleChat()["squad"] != None:
                                isBattleChat()["squad"].sendMessage(replaces(self.json_config["notifications"]["texts"]["squad"]))
                            elif self.json_config["notifications"]["my"]:
                                myMessage()
                        elif self.json_config["notifications"]["my"]:
                            myMessage()
                        if self.json_config["notifications"]["sound"]["enabled"]:
                            SoundGroups.g_instance.playSound2D(self.json_config["notifications"]["sound"]["soundName"].encode('utf8'))
                        if (len(self.getPercent()) == self.numberArrayPercent + 1) or self.numberArrayPercent + 1 == 5:
                            self.isWarning = True
                        self.numberArrayPercent += 1

saveShells = SaveShells()

def getShells():
    _tmp = g_sessionProvider.shared.ammo._AmmoController__ammo.values()
    return _tmp[0][0] + _tmp[1][0] + _tmp[2][0]

def _updateNumbersShells():
        while True:
            time.sleep(0.5)
            if g_sessionProvider.shared.ammo == None:
                break
            if len(g_sessionProvider.shared.ammo._AmmoController__ammo) != 3:
                continue
            saveShells.numberShellsAll = getShells()
            if g_sessionProvider.shared.ammo._AmmoController__gunSettings.isCassetteClip:
                saveShells.maxShellsInClip = g_sessionProvider.shared.ammo._AmmoController__gunSettings.clip.size
                saveShells.isClip = True;
            break

def _init_new_thread():
    time.sleep(0.5)
    saveShells.ammoCtrl = g_sessionProvider.shared.ammo
    def _onShellsUpdated(intCD, quantity, *args):
        saveShells.numberShellsCurrent = getShells()
        saveShells.shotsInClip = g_sessionProvider.shared.ammo.getCurrentShells()[1]
        saveShells.checkShells()
    saveShells._onShellsUpdated = _onShellsUpdated
    saveShells.ammoCtrl.onShellsUpdated += saveShells._onShellsUpdated

old___init__ = AmmoController.__init__

def new___init__(self, reloadingState = None):
    old___init__(self, reloadingState)
    if saveShells.enable:
        threading.Thread(target = _init_new_thread).start()

AmmoController.__init__ = new___init__

old_onEnterWorld = PlayerAvatar.onEnterWorld

def new_onEnterWorld(self, prereqs):
    old_onEnterWorld(self, prereqs)
    if saveShells.enable:
        threading.Thread(target = _updateNumbersShells).start()
        saveShells.isSopping = False
        print "[SaveShells] Starting mod"

PlayerAvatar.onEnterWorld = new_onEnterWorld

def stoppingMod():
    if saveShells.enable:
        if saveShells.isSopping:
            return
        saveShells.isWarning = False
        saveShells.ammoCtrl.onShellsUpdated -= saveShells._onShellsUpdated
        saveShells.isSopping = True
        saveShells.numberArrayPercent = 0;
        saveShells.isClip = False
        saveShells.shotsInClip = 0
        saveShells.isClipMessage = True
        saveShells.checkClip = 0
        print "[SaveShells] Stopping mod"

old_onLeaveWorld = PlayerAvatar.onLeaveWorld

def new_onLeaveWorld(self):
    old_onLeaveWorld(self)
    if saveShells.enable:
        stoppingMod()

PlayerAvatar.onLeaveWorld = new_onLeaveWorld

class Message(object):
    def pushMessage(self):
        SystemMessages.pushMessage('<font color="#FAFAFA">SaveShells by Wanket\nv' + _VER_MOD + ' for wot ' + _VER_GAME + '\nУспешно загружен.</font>', SystemMessages.SM_TYPE.Warning)
        saveShells.isHangar = True

    def pushDisableMessage(self):
        SystemMessages.pushMessage('<font color="#FAFAFA">SaveShells by Wanket\nv' + _VER_MOD + ' for wot ' + _VER_GAME + '\nУспешно загружен, но отключен.</font>', SystemMessages.SM_TYPE.Warning)
        saveShells.isHangar = True

messages = Message()  

class SaveShellsWindow(AbstractWindowView):

    def __init__(self):
        super(SaveShellsWindow, self).__init__()

    def _populate(self):
        super(SaveShellsWindow, self)._populate()
        self.flashObject.as_getSettings(saveShells.json_config["enabled"],
                                        saveShells.json_config["default_percent"],
                                        saveShells.json_config["notifications"]["my"],
                                        saveShells.json_config["notifications"]["squad"],
                                        saveShells.json_config["notifications"]["team"],
                                        
                                        [saveShells.json_config["notifications"]["levels"]["1"]["percent"],
                                        saveShells.json_config["notifications"]["levels"]["2"]["percent"],
                                        saveShells.json_config["notifications"]["levels"]["3"]["percent"],
                                        saveShells.json_config["notifications"]["levels"]["4"]["percent"],
                                        saveShells.json_config["notifications"]["levels"]["5"]["percent"],
                                        saveShells.json_config["notifications"]["levels"]["6"]["percent"],
                                        saveShells.json_config["notifications"]["levels"]["7"]["percent"],
                                        saveShells.json_config["notifications"]["levels"]["8"]["percent"],
                                        saveShells.json_config["notifications"]["levels"]["9"]["percent"],
                                        saveShells.json_config["notifications"]["levels"]["10"]["percent"]],
                                        
                                        [saveShells.json_config["notifications"]["classNames"]["lightTank"]["percent"],
                                        saveShells.json_config["notifications"]["classNames"]["mediumTank"]["percent"],
                                        saveShells.json_config["notifications"]["classNames"]["heavyTank"]["percent"],
                                        saveShells.json_config["notifications"]["classNames"]["AT-SPG"]["percent"],
                                        saveShells.json_config["notifications"]["classNames"]["SPG"]["percent"]],
                                        
                                        saveShells.json_config["autoReload"]["saveInOneClip"]["enabled"],
                                        saveShells.json_config["autoReload"]["saveInOneClip"]["percent"],
                                        saveShells.json_config["autoReload"]["saveInClip"]["enabled"])

    def onWindowClose(self):
        self.destroy()

    def uniq(self, a):
        b = []
        i = 0
        while (i < len(a)):
            if a[i] not in b:
                b.append(int(a[i]))
            i += 1
        return b

    def onApplyButton(self, enabled, defaultPercents, my, squad, team, levelPercents, classPercents, oneClip, oneClipPercent, clip):
        defaultPercents = self.uniq(defaultPercents)
        defaultPercents.sort(reverse=True)
        try:
            defaultPercents.remove(0)
        except Exception:
            pass
        if len(defaultPercents) == 0 or defaultPercents == [0]:
            enabled = False
            defaultPercents = [0]
        for i in range(len(levelPercents)):
            levelPercents[i] = self.uniq(levelPercents[i])
            levelPercents[i].sort(reverse=True)
            try:
                classPercents[i].remove(0)
            except Exception:
                pass
            if len(levelPercents[i]) == 0 or levelPercents[i] == [0]:
                saveShells.json_config["notifications"]["levels"][str(i + 1)]["enabled"] = False
                levelPercents[i] = [0]
            else:
                saveShells.json_config["notifications"]["levels"][str(i + 1)]["enabled"] = True
        for i in range(len(classPercents)):
            classPercents[i] = self.uniq(classPercents[i])
            classPercents[i].sort(reverse=True)
            try:
                classPercents[i].remove(0)
            except Exception:
                pass
            classCase = ["lightTank", "mediumTank", "heavyTank", "AT-SPG", "SPG"]
            if len(classPercents[i]) == 0 or classPercents[i] == [0]:
                saveShells.json_config["notifications"]["classNames"][classCase[i]]["enabled"] = False
                classPercents[i] = [0]
            else:
                saveShells.json_config["notifications"]["classNames"][classCase[i]]["enabled"] = True
        saveShells.json_config["enabled"] = enabled
        saveShells.json_config["default_percent"] = defaultPercents
        saveShells.json_config["notifications"]["my"] = my
        saveShells.json_config["notifications"]["squad"] = squad
        saveShells.json_config["notifications"]["team"] = team
        
        saveShells.json_config["notifications"]["levels"]["1"]["percent"] = levelPercents[0]
        saveShells.json_config["notifications"]["levels"]["2"]["percent"] = levelPercents[1]
        saveShells.json_config["notifications"]["levels"]["3"]["percent"] = levelPercents[2]
        saveShells.json_config["notifications"]["levels"]["4"]["percent"] = levelPercents[3]
        saveShells.json_config["notifications"]["levels"]["5"]["percent"] = levelPercents[4]
        saveShells.json_config["notifications"]["levels"]["6"]["percent"] = levelPercents[5]
        saveShells.json_config["notifications"]["levels"]["7"]["percent"] = levelPercents[6]
        saveShells.json_config["notifications"]["levels"]["8"]["percent"] = levelPercents[7]
        saveShells.json_config["notifications"]["levels"]["9"]["percent"] = levelPercents[8]
        saveShells.json_config["notifications"]["levels"]["10"]["percent"] = levelPercents[9]
        
        saveShells.json_config["notifications"]["classNames"]["lightTank"]["percent"] = classPercents[0]
        saveShells.json_config["notifications"]["classNames"]["mediumTank"]["percent"] = classPercents[1]
        saveShells.json_config["notifications"]["classNames"]["heavyTank"]["percent"] = classPercents[2]
        saveShells.json_config["notifications"]["classNames"]["AT-SPG"]["percent"] = classPercents[3]
        saveShells.json_config["notifications"]["classNames"]["SPG"]["percent"] = classPercents[4]
        
        saveShells.json_config["autoReload"]["saveInOneClip"]["enabled"] = oneClip
        saveShells.json_config["autoReload"]["saveInOneClip"]["percent"] = oneClipPercent
        saveShells.json_config["autoReload"]["saveInClip"]["enabled"] = clip
        
        with open("./res_mods/configs/mod_save_shells/config.json", "w") as f:
            json.dump(saveShells.json_config, f, ensure_ascii=False,  sort_keys=True, indent=4, separators=(',', ': '))

g_entitiesFactories.addSettings(ViewSettings("SaveShells", SaveShellsWindow, "SaveShells.swf", ViewTypes.WINDOW, None, ScopeTemplates.VIEW_SCOPE))

def saveShells_callback():
    g_appLoader.getDefLobbyApp().loadView("SaveShells")

with open("./res_mods/configs/mod_save_shells/icons/logo.png", 'rb') as fh:
    icon = fh.read().encode("base64").replace('\n', '')

g_modsListApi.addMod(
    id = "SaveShellsMod_0", 
    name = 'SaveShells', 
    description = 'Настройка мода SaveShells', 
    icon = icon, 
    enabled = True, 
    login = True, 
    lobby = True, 
    callback = saveShells_callback
)

def new_onBecomePlayer(self):
    old_onBecomePlayer(self)
    if not saveShells.isHangar:
        if saveShells.enable:
            messages.pushMessage()
        else:
            messages.pushDisableMessage

old_onBecomePlayer = Account.onBecomePlayer
Account.onBecomePlayer = new_onBecomePlayer

import WWISE

def new_WG_loadBanks(xmlPath, banks, isHangar):
    if not isHangar:
        if banks == " ":
            banks = 'SaveShells.bnk'
        else:
            banks += " ; SaveShells.bnk"
    print banks
    return orig_WG_loadBanks(xmlPath, banks, isHangar)

orig_WG_loadBanks = WWISE.WG_loadBanks
WWISE.WG_loadBanks = new_WG_loadBanks

print "[SaveShells] Mod loaded"
print "[SaveShells] Version: %s" % _VER_MOD
if not saveShells.enable:
    print "WARNING: [SaveShells] Mod is disable"
