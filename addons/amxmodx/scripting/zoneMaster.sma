/*
*
*	Zone Master by RedSMURF
*
*
*	Description:
*
*	Cvars:
*		None
*
*	Commands:
*       say /zm                 "Opens the Zone Master menu."
*       say_team /zm            "Opens the Zone Master menu."
*       say /zonemaster         "Opens the Zone Master menu."
*       say_team /zonemaster    "Opens the Zone Master menu."
*       zm_reload               "Reloads the configuration file."
*       zonemaster_reload       "Reloads the configuration file."
*
*	Changelog:
*       v1.0: Initial release.
*
*/

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <xs>

#if !defined MAX_PLAYERS
    #define MAX_PLAYERS 32
#endif

#if !defined MAX_VALUE_LENGTH
    #define MAX_VALUE_LENGTH 64
#endif

#if !defined MAX_RESOURCE_PATH_LENGTH
    #define MAX_RESOURCE_PATH_LENGTH 128
#endif

#if !defined MAX_FILE_CELL_SIZE
    #define MAX_FILE_CELL_SIZE 192
#endif

#if !defined MAX_PLATFORM_PATH_LENGTH
    #define MAX_PLATFORM_PATH_LENGTH 256
#endif

#define MAX_ENT                     32
#define MASTER_KEY                  112233
#define MASTER_ARRAY_ITEM           pev_iuser1
#define TASK_WEAPON_IDLE            332211
#define FADE_IN                     0
#define FADE_OUT                    1
#define FADE_MODULATE               2
#define FADE_STAYOUT                4

#define MEMBER_OWNER                41
#define MEMBER_AMMO_TYPE            49
#define MEMBER_NEXT_PRIMARY         46
#define MEMBER_NEXT_SECONDARY		47
#define MEMBER_NEXT_IDLE            48
#define MEMBER_IN_RELOAD            54
#define MEMBER_IN_SPECIAL_RELOAD    55
#define MEMBER_NEXT_ATTACK          83

new const PLUGIN_VERSION[]       = "1.0"
new const Float:DELAY_ON_CONNECT = 1.0
new const ERROR_FILE[]           = "ZoneMaster_ERRORS.log"

enum
{
    SECTION_NONE,
    SECTION_MAIN_SETTINGS,
    SECTION_MASTER,
    SECTION_MASTER_AMMO,
    SECTION_MASTER_BOMB,
    SECTION_MASTER_CLOCK,
    SECTION_MASTER_HEALTH,
    SECTION_MASTER_LIGHTNING,
    SECTION_MASTER_MASK,
    SECTION_MASTER_MASK2,
    SECTION_MASTER_SHIELD,
    SECTION_MASTER_SKULL,
    SECTION_MASTER_SKULL2,
    SECTION_MASTER_STUN,
    SECTION_MASTER_STUN2,
    SECTION_MASTER_UP,
    SECTION_MASTER_WINGS
}

enum
{
    CLASS_AMMO,
    CLASS_BOMB,
    CLASS_CLOCK,
    CLASS_HEALTH,
    CLASS_LIGHTNING,
    CLASS_MASK,
    CLASS_MASK2,
    CLASS_SHIELD,
    CLASS_SKULL,
    CLASS_SKULL2,
    CLASS_STUN,
    CLASS_STUN2,
    CLASS_UP,
    CLASS_WINGS
}

enum
{
    DTYPE_FLOAT,
    DTYPE_FLOAT_RANGE,
    DTYPE_INT,
    DTYPE_INT_RANGE,
    DTYPE_BOOL,
    DTYPE_FLAGS,
    DTYPE_VECTOR,
    DTYPE_VECTOR_4,
    DTYPE_STRING_MODEL,
    DTYPE_STRING_SOUND,
    DTYPE_STRING_SPRITE
}

enum
{
    FLAG_ICON               = (1 << 0),
    FLAG_ACTIVE_DELAY       = (1 << 1),
    FLAG_ACTIVE_DURATION    = (1 << 2),

    FLAG_SELECT             = (1 << 3),
    FLAG_ACTIVE             = (1 << 4)
}

enum
{
    STATUS_DEFAULT,
    STATUS_FORCE_ENABLE,
    STATUS_FORCE_DISABLE
}

enum
{
    TEAM_NONE,
    TEAM_T,
    TEAM_CT,
    TEAM_BOTH
}

enum
{
    ANIM_IDLE,
    ANIM_SPIN,
    ANIM_FLOAT,
    ANIM_SPIN_FLOAT
}

enum
{
    SOUND_MENU_NAV,
    SOUND_MENU_REMOVE,
    SOUND_MENU_ALERT,

    SOUND_ENABLED,
    SOUND_DISABLED,
    SOUND_CLIP1
}

enum
{
    MODE_RELATIVE,
    MODE_ABSOLUTE
}

enum
{
    STUN2_DIRECTION_FORWARD,
    STUN2_DIRECTION_RANDOM
}

enum _:MAIN_SETTINGS
{
    SETTING_DEFAULT_FLAGS,
    SETTING_DEFAULT_TEAM,
    SETTING_DEFAULT_ANIM,
    Float:SETTING_DEFAULT_ACTIVE_CHANCE,
    Float:SETTING_DEFAULT_ACTIVE_DELAY[2],
    Float:SETTING_DEFAULT_ACTIVE_DURATION[2],
    Float:SETTING_DEFAULT_ACTIVE_COOLDOWN[2],
    SETTING_DEFAULT_ICON[MAX_RESOURCE_PATH_LENGTH],
    Float:SETTING_DEFAULT_ICON_SCALE,
    SETTING_DEFAULT_ICON_ALPHA,
    SETTING_DEFAULT_CLASS,

    Float:SETTING_DEFAULT_AMMO_FREQ[2],
    Float:SETTING_DEFAULT_AMMO_CLIP[2],
    Float:SETTING_DEFAULT_AMMO_AMMO[2],
    SETTING_DEFAULT_AMMO_MODE,
    bool:SETTING_DEFAULT_AMMO_OVERFLOW,

    Float:SETTING_DEFAULT_MASTER_FREQ[2],
    SETTING_DEFAULT_MASTER_HE_SUPPLY[2],
    SETTING_DEFAULT_MASTER_FB_SUPPLY[2],
    SETTING_DEFAULT_MASTER_SMOKE_SUPPLY[2],
    SETTING_DEFAULT_MASTER_HE_LIMIT,
    SETTING_DEFAULT_MASTER_FB_LIMIT,
    SETTING_DEFAULT_MASTER_SMOKE_LIMIT,
    bool:SETTING_DEFAULT_MASTER_OVERFLOW,

    Float:SETTING_DEFAULT_CLOCK_RELOAD_SPEED[2],
    Float:SETTING_DEFAULT_CLOCK_ATTACK_SPEED[2],
    Float:SETTING_DEFAULT_CLOCK_DEPLOY_SPEED[2],
    Float:SETTING_DEFAULT_CLOCK_RECOIL_SETTING[2],

    Float:SETTING_DEFAULT_HEALTH_FREQ[2],
    Float:SETTING_DEFAULT_HEALTH_RATE[2],
    Float:SETTING_DEFAULT_HEALTH_LIMIT,
    bool:SETTING_DEFAULT_HEALTH_OVERFLOW,

    Float:SETTING_DEFAULT_LIGHTNING_SPEED[2],

    Float:SETTING_DEFAULT_MASK_ALPHA[2],
    bool:SETTING_DEFAULT_MASK_FOOTSTEP,

    SETTING_DEFAULT_MASK2_MODEL_FLAG,

    Float:SETTING_DEFAULT_SHIELD_ARMOR_FREQ[2],
    SETTING_DEFAULT_SHIELD_ARMOR[2],
    SETTING_DEFAULT_SHIELD_ARMOR_LIMIT,
    bool:SETTING_DEFAULT_SHIELD_ARMOR_OVERFLOW,
    SETTING_DEFAULT_SHIELD_ARMOR_TYPE,
    Float:SETTING_DEFAULT_SHIELD_ABSORB[2],
    Float:SETTING_DEFAULT_SHIELD_REFLECT[2],

    Float:SETTING_DEFAULT_SKULL_DAMAGE[2],
    Float:SETTING_DEFAULT_SKULL_BLOOD[2],

    Float:SETTING_DEFAULT_SKULL2_FREQ[2],
    Float:SETTING_DEFAULT_SKULL2_DAMAGE[2],
    SETTING_DEFAULT_SKULL2_DAMAGE_TYPE,
    Float:SETTING_DEFAULT_SKULL2_LIMIT,
    bool:SETTING_DEFAULT_SKULL2_OVERFLOW,

    Float:SETTING_DEFAULT_STUN_FREQ[2],
    SETTING_DEFAULT_STUN_AMPLITUDE,
    SETTING_DEFAULT_STUN_FREQUENCY,
    SETTING_DEFAULT_STUN_COLOR_MIN[4],
    SETTING_DEFAULT_STUN_COLOR_MAX[4],
    SETTING_DEFAULT_STUN_FOV,

    Float:SETTING_DEFAULT_STUN2_FREQ[2],
    SETTING_DEFAULT_STUN2_DAMAGE[2],
    SETTING_DEFAULT_STUN2_DIRECTION,
    bool:SETTING_DEFAULT_STUN2_KILL,

    SETTING_DEFAULT_UP_JUMP,
    Float:SETTING_DEFAULT_UP_GRAVITY[2],

    bool:SETTING_DEFAULT_WINGS_NOCLIP,
    bool:SETTING_DEFAULT_WINGS_GODMODE,

    bool:SETTING_MASTER_LOAD,
    bool:SETTING_MASTER_DEFAULT,
    Float:SETTING_MASTER_CHECK,
    Float:SETTING_OFFSET_BASE,
    Float:SETTING_OFFSET[2],
    Float:SETTING_OFFSET_STEP,
    SETTING_ALPHA_INACTIVE,

    Float:SETTING_SIZE_BASE,
    Float:SETTING_SIZE_HEIGHT[2],
    Float:SETTING_SIZE_WIDTH[2],
    Float:SETTING_SIZE_DEPTH[2],

    SETTING_SOUND_MENU_NAV[MAX_RESOURCE_PATH_LENGTH],
    SETTING_SOUND_MENU_REMOVE[MAX_RESOURCE_PATH_LENGTH],
    SETTING_SOUND_MENU_ALERT[MAX_RESOURCE_PATH_LENGTH],
    SETTING_SOUND_SUITCHARGE[MAX_RESOURCE_PATH_LENGTH],
    SETTING_SOUND_BLIP2[MAX_RESOURCE_PATH_LENGTH],
    SETTING_SOUND_CLIP1[MAX_RESOURCE_PATH_LENGTH],

    SETTING_BEAM,
    SETTING_BEAM_WIDTH,
    SETTING_BEAM_ALPHA,
    SETTING_COLOR_ACTIVE[3],
    SETTING_COLOR_INACTIVE[3]
}

enum _:MASTER
{
    MASTER_ID,
    MASTER_ITEM,
    MASTER_FLAGS,
    MASTER_STATUS,
    MASTER_TEAM,
    MASTER_ANIM,
    Float:MASTER_ACTIVE_CHANCE,
    Float:MASTER_ACTIVE_DELAY[2],
    Float:MASTER_ACTIVE_DURATION[2],
    Float:MASTER_ACTIVE_COOLDOWN[2],

    MASTER_ICON[MAX_RESOURCE_PATH_LENGTH],
    Float:MASTER_ICON_SCALE,
    MASTER_ICON_ALPHA,
    MASTER_NAME[MAX_VALUE_LENGTH],

    Float:MASTER_SCALE[3],
    Float:MASTER_ORIGIN[3],
    Float:MASTER_CORNERS[24],
    Float:MASTER_MINS[3],
    Float:MASTER_MAXS[3],
    Float:MASTER_NEXT_ENABLE,
    Float:MASTER_NEXT_DISABLE,

    MASTER_CLASS,
    Array:MASTER_DATA
}

enum _:MASTER_AMMO
{
    Float:AMMO_FREQ[2],
    Float:AMMO_CLIP[2],
    Float:AMMO_AMMO[2],
    AMMO_MODE,
    bool:AMMO_OVERFLOW
}

enum _:MASTER_BOMB
{
    Float:MASTER_FREQ[2],
    MASTER_HE_SUPPLY[2],
    MASTER_FB_SUPPLY[2],
    MASTER_SMOKE_SUPPLY[2],
    MASTER_HE_LIMIT,
    MASTER_FB_LIMIT,
    MASTER_SMOKE_LIMIT,
    bool:MASTER_OVERFLOW
}

enum _:MASTER_CLOCK
{
    Float:CLOCK_RELOAD_SPEED[2],
    Float:CLOCK_ATTACK_SPEED[2],
    Float:CLOCK_DEPLOY_SPEED[2],
    Float:CLOCK_RECOIL_SETTING[2]
}

enum _:MASTER_HEALTH
{
    Float:HEALTH_FREQ[2],
    Float:HEALTH_RATE[2],
    Float:HEALTH_LIMIT,
    bool:HEALTH_OVERFLOW
}

enum _:MASTER_LIGHTNING
{
    Float:LIGHTNING_SPEED[2]
}

enum _:MASTER_MASK
{
    Float:MASK_ALPHA[2],
    bool:MASK_FOOTSTEP
}

enum _:MASTER_MASK2
{
    MASK2_MODEL_FLAG
}

enum _:MASTER_SHIELD
{
    Float:SHIELD_ARMOR_FREQ[2],
    SHIELD_ARMOR[2],
    SHIELD_ARMOR_LIMIT,
    bool:SHIELD_ARMOR_OVERFLOW,
    SHIELD_ARMOR_TYPE,
    Float:SHIELD_ABSORB[2],
    Float:SHIELD_REFLECT[2]
}

enum _:MASTER_SKULL
{
    Float:SKULL_DAMAGE[2],
    Float:SKULL_BLOOD[2]
}

enum _:MASTER_SKULL2
{
    Float:SKULL2_FREQ[2],
    Float:SKULL2_DAMAGE[2],
    SKULL2_DAMAGE_TYPE,
    Float:SKULL2_LIMIT,
    bool:SKULL2_OVERFLOW
}

enum _:MASTER_STUN
{
    Float:STUN_FREQ[2],
    STUN_AMPLITUDE,
    STUN_FREQUENCY,
    STUN_COLOR_MIN[4],
    STUN_COLOR_MAX[4],
    STUN_FOV
}

enum _:MASTER_STUN2
{
    Float:STUN2_FREQ[2],
    STUN2_DAMAGE[2],
    STUN2_DIRECTION,
    bool:STUN2_KILL
}

enum _:MASTER_UP
{
    UP_JUMP,
    Float:UP_GRAVITY[2],
}

enum _:MASTER_WINGS
{
    bool:WINGS_NOCLIP,
    bool:WINGS_GODMODE
}

enum _:PLAYER_DATA
{
    PDATA_MASTER_GHOST,
    PDATA_MASTER_MENU,
    bool:PDATA_MASTER_ACTION,
    bool:PDATA_SCALE_UP,
    PDATA_SCALE_FACTOR,
    Float:PDATA_OFFSET,
    Float:PDATA_NEXT_OFFSET,

    Float:PDATA_NEXT_AMMO,
    Float:PDATA_NEXT_BOMB,
    bool:PDATA_CLOCK,
    Float:PDATA_CLOCK_RELOAD_SPEED,
    Float:PDATA_CLOCK_ATTACK_SPEED,
    Float:PDATA_CLOCK_DEPLOY_SPEED,
    Float:PDATA_CLOCK_RECOIL_SETTING,
    Float:PDATA_NEXT_HEALTH,
    bool:PDATA_LIGHTNING,
    Float:PDATA_LIGHTNING_LAST,
    Float:PDATA_LIGHTNING_SPEED,
    bool:PDATA_MASK,
    Float:PDATA_MASK_LAST,
    bool:PDATA_MASK2,
    bool:PDATA_MASK2_CHANGE,
    PDATA_MASK2_MODEL[MAX_VALUE_LENGTH],
    bool:PDATA_SHIELD,
    bool:PDATA_SHIELD_REFLECTED,
    Float:PDATA_SHIELD_ABSORB,
    Float:PDATA_SHIELD_REFLECT,
    Float:PDATA_NEXT_SHIELD,
    bool:PDATA_SKULL,
    Float:PDATA_SKULL_DAMAGE,
    Float:PDATA_SKULL_BLOOD,
    Float:PDATA_NEXT_DAMAGE,
    bool:PDATA_STUN,
    PDATA_STUN_FOV,
    PDATA_STUN_FOV_LAST,
    Float:PDATA_NEXT_STUN,
    bool:PDATA_STUN2,
    Float:PDATA_NEXT_STUN2,
    bool:PDATA_UP,
    PDATA_UP_JUMP,
    PDATA_UP_JUMP_LAST,
    Float:PDATA_UP_GRAVITY,
    Float:PDATA_UP_GRAVITY_LAST,
    bool:PDATA_WINGS,
    bool:PDATA_WINGS_NOCLIP,
    bool:PDATA_WINGS_GODMODE
}

enum
{
    MENU_ROOT,
    MENU_CREATE,
    MENU_STATUS,
    MENU_REMOVE,
    MENU_SCALE
}

enum
{
    ROOT_CREATE,
    ROOT_STATUS,
    ROOT_REMOVE,
    ROOT_SAVE,

    ROOT_NOCLIP = 5,
    ROOT_GODMODE
}

enum
{
    STATUS_NEXT,
    STATUS_BACK,

    STATUS_CURRENT = 3,
    STATUS_ALL_ENABLE,
    STATUS_ALL_DISABLE,
    STATUS_ALL_DEFAULT
}

enum
{
    REMOVE_NEXT,
    REMOVE_BACK,

    REMOVE_CURRENT = 3,
    REMOVE_ALL
}

enum
{
    SCALE_HEIGHT,
    SCALE_WIDTH,
    SCALE_DEPTH,

    SCALE_FACTOR = 4,
    SCALE_MODE,
    SCALE_PLACE
}

new const g_iWeaponMaxClip[] =
{
    0,      13,     0,    10,     1,     7,     1,    30,    30,     1,
    30,     20,    25,     5,    35,    25,    12,    20,    10,    30,
    100,     8,    30,    30,     5,     1,     7,    30,    30,     0,
    50
}

new const g_iWeaponMaxBp[] =
{
    0,      52,     0,    90,     0,    32,     0,   100,    90,     1,
    120,   100,   100,    90,    90,    90,   100,   120,    30,   120,
    200,    32,    90,   120,    90,     0,    35,    90,    90,     0,
    100
}

new g_szMenuHandler[][] =
{
    "menuHandlerRoot",
    "menuHandlerCreate",
    "menuHandlerStatus",
    "menuHandlerRemove",
    "menuHandlerScale"
}

new Array:g_aMaster,
    Array:g_aMasterConfig,
    g_eSettings[MAIN_SETTINGS],
    g_ePlayerData[MAX_PLAYERS + 1][PLAYER_DATA],
    bool:g_bFileWasRead = false,
    g_iMaster, g_iMasterConfig,
    g_iDamage, g_iAmmoPickup, g_iWeapPickup, g_iScreenFade, g_iScreenShake, g_iSetFov,
    g_szWeapon[32], g_iMaxPlayers

new g_szStatus[][] = {"MASTER_DEFAULT", "MASTER_ENABLED", "MASTER_DISABLED"}
new g_szStatusChat[][] = {"MASTER_CHAT_DEFAULT", "MASTER_CHAT_ENABLED", "MASTER_CHAT_DISABLED"}
new g_szStatusColor[][] = {"\d", "\y", "\r"}

new g_szTModels[][] = {"terror", "leet", "arctic", "guerilla"}
new g_szCTModels[][] = {"urban", "gsg9", "sas", "gign"}
new Float:g_fScaleFactor[] = {5.0, 10.0, 20.0, 30.0, 45.0, 60.0}
new g_szCN[] = "zonemaster"

public plugin_init()
{
    register_plugin("Zone Master", PLUGIN_VERSION, "RedSMURF")

    register_clcmd("say /zm", "cmdMenu", ADMIN_RCON)
    register_clcmd("say_team /zm", "cmdMenu", ADMIN_RCON)
    register_clcmd("say /zonemaster", "cmdMenu", ADMIN_RCON)
    register_clcmd("say_team /zonemaster", "cmdMenu", ADMIN_RCON)
    register_concmd("mz_reload", "cmdReload", ADMIN_RCON, "-- Reload the configuration file")
    register_concmd("zonemaster_reload", "cmdReload", ADMIN_RCON, "-- Reload the configuration file")

    register_dictionary("ZoneMaster.txt")

    register_forward(FM_UpdateClientData, "fwdUpdateClientData", 1)
    register_forward(FM_AddToFullPack, "fwdAddToFullPack", 1)
    RegisterHam(Ham_Spawn, "info_target", "fwdSpawn", 1)
    RegisterHam(Ham_Player_PreThink, "player", "fwdPreThink")
    RegisterHam(Ham_TakeDamage, "player", "fwdTakeDamage")
    RegisterHam(Ham_Killed, "player", "fwdKilled", 1)
    RegisterHam(Ham_CS_Player_ResetMaxSpeed, "player", "fwdResetMaxSpeedPlayer", 1)

    for ( new i = CSW_P228; i <= CSW_P90; i ++ )
    {
        if ( get_weaponname(i, g_szWeapon, charsmax(g_szWeapon)) )
        {
            RegisterHam(Ham_Weapon_Reload, g_szWeapon, "fwdWeaponReload", 1)
            RegisterHam(Ham_Weapon_PrimaryAttack, g_szWeapon, "fwdWeaponAttack", 1)
            RegisterHam(Ham_Weapon_SecondaryAttack, g_szWeapon, "fwdWeaponAttack", 1)
            RegisterHam(Ham_Item_Deploy, g_szWeapon, "fwdWeaponDeploy", 1)
        }
    }

    g_iDamage = get_user_msgid("Damage")
    g_iAmmoPickup = get_user_msgid("AmmoPickup")
    g_iWeapPickup = get_user_msgid("WeapPickup")
    g_iScreenFade = get_user_msgid("ScreenFade")
    g_iScreenShake = get_user_msgid("ScreenShake")
    g_iSetFov = get_user_msgid("SetFOV")
    g_iMaxPlayers = get_maxplayers()

    register_logevent("eventRoundStart", 2, "1=Round_Start")
    set_task(0.1, "masterTask", .flags = "b")
    masterInit()
}

public plugin_precache()
{
    g_aMaster = ArrayCreate(MASTER)
    g_aMasterConfig = ArrayCreate(MASTER)

    ReadFile()
}

public plugin_end()
{
    new eMaster[MASTER]

    for ( new i = 0; i < g_iMaster; i ++ )
    {
        ArrayGetArray(g_aMaster, i, eMaster)
        ArrayDestroy(eMaster[MASTER_DATA])
    }

    for ( new i = 0; i < g_iMasterConfig; i ++ )
    {
        ArrayGetArray(g_aMasterConfig, i, eMaster)
        ArrayDestroy(eMaster[MASTER_DATA])
    }

    ArrayDestroy(g_aMaster)
    ArrayDestroy(g_aMasterConfig)
}

public cmdMenu(id, iLevel, iCmd)
{
    if ( !cmd_access(id, iLevel, iCmd, 1) )
        return PLUGIN_HANDLED

    masterSound(id, SOUND_MENU_NAV)
    masterMenu(id, MENU_ROOT)

    return PLUGIN_HANDLED
}

public cmdReload(id, iLevel, iCmd)
{
    if ( !cmd_access(id, iLevel, iCmd, 1) )
        return PLUGIN_HANDLED

    ReadFile()
    console_print(id, "The configuration file has been reloaded successfully !")

    return PLUGIN_HANDLED
}

public client_command(id)
{
    if ( !g_ePlayerData[id][PDATA_MASTER_GHOST] )
        return PLUGIN_CONTINUE

    new szCmd[16]
    read_argv(0, szCmd, charsmax(szCmd))

    if ( contain(szCmd, "weapon_") != -1 ||
    equal(szCmd, "invnext") ||
    equal(szCmd, "invprev") ||
    equal(szCmd, "lastinv") )
        return PLUGIN_HANDLED

    return PLUGIN_CONTINUE
}

public eventRoundStart()
{
    if ( !g_iMaster )
        return PLUGIN_HANDLED

    new eMaster[MASTER], Float:fCurrentTime
    fCurrentTime = get_gametime()

    for ( new i = 1; i <= g_iMaxPlayers; i ++ )
        masterResetPlayer(i)

    for ( new i = 0; i < g_iMaster; i ++ )
    {
        ArrayGetArray(g_aMaster, i, eMaster)
        if ( eMaster[MASTER_STATUS] != STATUS_DEFAULT )
            continue

        masterReset(eMaster)

        if ( eMaster[MASTER_ACTIVE_CHANCE] >= random_float(0.0, 1.0) )
        {
            if ( eMaster[MASTER_FLAGS] & FLAG_ACTIVE_DELAY )
                eMaster[MASTER_NEXT_ENABLE] = fCurrentTime + random_float(eMaster[MASTER_ACTIVE_DELAY][0], eMaster[MASTER_ACTIVE_DELAY][1])
            else
                eMaster[MASTER_FLAGS] |= FLAG_ACTIVE
        }

        ArraySetArray(g_aMaster, i, eMaster)
    }

    return PLUGIN_HANDLED
}

ReadFile()
{
    if ( g_bFileWasRead )
    {
        for ( new id = 1; id <= g_iMaxPlayers; id ++ )
            if ( is_user_connected(id))
                UpdateData(id)

        ArrayClear(g_aMasterConfig)
        g_iMasterConfig = 0
    }

    new g_szFileName[MAX_RESOURCE_PATH_LENGTH]
    get_configsdir(g_szFileName, charsmax(g_szFileName))
    add(g_szFileName, charsmax(g_szFileName), "/ZoneMaster.ini")

    new iFile
    iFile = fopen(g_szFileName, "rt")

    if ( !iFile )
    {
        set_fail_state("An error occured during the opening of the configuration file !")
    }

    new szData[MAX_FILE_CELL_SIZE],
        szKey[MAX_VALUE_LENGTH],
        szValue[MAX_RESOURCE_PATH_LENGTH],
        eMaster[MASTER], iSection = SECTION_NONE, iLine, iPos,
        eMasterAmmo[MASTER_AMMO], eMasterBomb[MASTER_BOMB], eMasterClock[MASTER_CLOCK],
        eMasterHealth[MASTER_HEALTH], eMasterLightning[MASTER_LIGHTNING], eMasterMask[MASTER_MASK],
        eMasterMask2[MASTER_MASK2], eMasterShield[MASTER_SHIELD], eMasterSkull[MASTER_SKULL], eMasterSkull2[MASTER_SKULL2],
        eMasterStun[MASTER_STUN], eMasterStun2[MASTER_STUN2], eMasterUp[MASTER_UP],  eMasterWings[MASTER_WINGS]

    while( !feof(iFile) )
    {
        iLine ++
        fgets(iFile, szData, charsmax(szData))
        trim(szData)

        switch( szData[0] )
        {
            case EOS, ';', '#':
            {
                continue
            }
            case '[':
            {
                if ( szData[strlen(szData) - 1] == ']' )
                {
                    replace(szData, charsmax( szData ), "[", "")
                    replace(szData, charsmax( szData ), "]", "")
                    trim(szData)

                    if ( equali(szData, "Main Settings") )
                    {
                        iSection = SECTION_MAIN_SETTINGS
                        continue
                    }
                    else
                    {
                        if ( g_iMasterConfig )
                            ArrayPushArray(g_aMasterConfig, eMaster)

                        copy(eMaster[MASTER_NAME], charsmax(eMaster[MASTER_NAME]), szData)
                        copy(eMaster[MASTER_ICON], charsmax(eMaster[MASTER_ICON]), g_eSettings[SETTING_DEFAULT_ICON])
                        eMaster[MASTER_FLAGS]                       = g_eSettings[SETTING_DEFAULT_FLAGS]
                        eMaster[MASTER_TEAM]                        = g_eSettings[SETTING_DEFAULT_TEAM]
                        eMaster[MASTER_ANIM]                        = g_eSettings[SETTING_DEFAULT_ANIM]
                        eMaster[MASTER_ACTIVE_CHANCE]               = g_eSettings[SETTING_DEFAULT_ACTIVE_CHANCE]
                        eMaster[MASTER_ACTIVE_DELAY][0]             = g_eSettings[SETTING_DEFAULT_ACTIVE_DELAY][0]
                        eMaster[MASTER_ACTIVE_DELAY][1]             = g_eSettings[SETTING_DEFAULT_ACTIVE_DELAY][1]
                        eMaster[MASTER_ACTIVE_DURATION][0]          = g_eSettings[SETTING_DEFAULT_ACTIVE_DURATION][0]
                        eMaster[MASTER_ACTIVE_DURATION][1]          = g_eSettings[SETTING_DEFAULT_ACTIVE_DURATION][1]
                        eMaster[MASTER_ACTIVE_COOLDOWN][0]          = g_eSettings[SETTING_DEFAULT_ACTIVE_COOLDOWN][0]
                        eMaster[MASTER_ACTIVE_COOLDOWN][1]          = g_eSettings[SETTING_DEFAULT_ACTIVE_COOLDOWN][1]
                        eMaster[MASTER_ICON_SCALE]                  = g_eSettings[SETTING_DEFAULT_ICON_SCALE]
                        eMaster[MASTER_ICON_ALPHA]                  = g_eSettings[SETTING_DEFAULT_ICON_ALPHA]
                        eMaster[MASTER_CLASS]                       = g_eSettings[SETTING_DEFAULT_CLASS]

                        eMasterAmmo[AMMO_FREQ][0]                   = g_eSettings[SETTING_DEFAULT_AMMO_FREQ][0]
                        eMasterAmmo[AMMO_FREQ][1]                   = g_eSettings[SETTING_DEFAULT_AMMO_FREQ][1]
                        eMasterAmmo[AMMO_CLIP][0]                   = g_eSettings[SETTING_DEFAULT_AMMO_CLIP][0]
                        eMasterAmmo[AMMO_CLIP][1]                   = g_eSettings[SETTING_DEFAULT_AMMO_CLIP][1]
                        eMasterAmmo[AMMO_AMMO][0]                   = g_eSettings[SETTING_DEFAULT_AMMO_AMMO][0]
                        eMasterAmmo[AMMO_AMMO][1]                   = g_eSettings[SETTING_DEFAULT_AMMO_AMMO][1]
                        eMasterAmmo[AMMO_MODE]                      = g_eSettings[SETTING_DEFAULT_AMMO_MODE]
                        eMasterAmmo[AMMO_OVERFLOW]                  = g_eSettings[SETTING_DEFAULT_AMMO_OVERFLOW]

                        eMasterBomb[MASTER_FREQ][0]                   = g_eSettings[SETTING_DEFAULT_MASTER_FREQ][0]
                        eMasterBomb[MASTER_FREQ][1]                   = g_eSettings[SETTING_DEFAULT_MASTER_FREQ][1]
                        eMasterBomb[MASTER_HE_SUPPLY][0]              = g_eSettings[SETTING_DEFAULT_MASTER_HE_SUPPLY][0]
                        eMasterBomb[MASTER_HE_SUPPLY][1]              = g_eSettings[SETTING_DEFAULT_MASTER_HE_SUPPLY][1]
                        eMasterBomb[MASTER_FB_SUPPLY][0]              = g_eSettings[SETTING_DEFAULT_MASTER_FB_SUPPLY][0]
                        eMasterBomb[MASTER_FB_SUPPLY][1]              = g_eSettings[SETTING_DEFAULT_MASTER_FB_SUPPLY][1]
                        eMasterBomb[MASTER_SMOKE_SUPPLY][0]           = g_eSettings[SETTING_DEFAULT_MASTER_SMOKE_SUPPLY][0]
                        eMasterBomb[MASTER_SMOKE_SUPPLY][1]           = g_eSettings[SETTING_DEFAULT_MASTER_SMOKE_SUPPLY][1]
                        eMasterBomb[MASTER_HE_LIMIT]                  = g_eSettings[SETTING_DEFAULT_MASTER_HE_LIMIT]
                        eMasterBomb[MASTER_FB_LIMIT]                  = g_eSettings[SETTING_DEFAULT_MASTER_FB_LIMIT]
                        eMasterBomb[MASTER_SMOKE_LIMIT]               = g_eSettings[SETTING_DEFAULT_MASTER_SMOKE_LIMIT]
                        eMasterBomb[MASTER_OVERFLOW]                  = g_eSettings[SETTING_DEFAULT_MASTER_OVERFLOW]

                        eMasterClock[CLOCK_RELOAD_SPEED][0]         = g_eSettings[SETTING_DEFAULT_CLOCK_RELOAD_SPEED][0]
                        eMasterClock[CLOCK_RELOAD_SPEED][1]         = g_eSettings[SETTING_DEFAULT_CLOCK_RELOAD_SPEED][1]
                        eMasterClock[CLOCK_ATTACK_SPEED][0]         = g_eSettings[SETTING_DEFAULT_CLOCK_ATTACK_SPEED][0]
                        eMasterClock[CLOCK_ATTACK_SPEED][1]         = g_eSettings[SETTING_DEFAULT_CLOCK_ATTACK_SPEED][1]
                        eMasterClock[CLOCK_DEPLOY_SPEED][0]         = g_eSettings[SETTING_DEFAULT_CLOCK_DEPLOY_SPEED][0]
                        eMasterClock[CLOCK_DEPLOY_SPEED][1]         = g_eSettings[SETTING_DEFAULT_CLOCK_DEPLOY_SPEED][1]
                        eMasterClock[CLOCK_RECOIL_SETTING][0]       = g_eSettings[SETTING_DEFAULT_CLOCK_RECOIL_SETTING][0]
                        eMasterClock[CLOCK_RECOIL_SETTING][1]       = g_eSettings[SETTING_DEFAULT_CLOCK_RECOIL_SETTING][1]

                        eMasterHealth[HEALTH_FREQ][0]               = g_eSettings[SETTING_DEFAULT_HEALTH_FREQ][0]
                        eMasterHealth[HEALTH_FREQ][1]               = g_eSettings[SETTING_DEFAULT_HEALTH_FREQ][1]
                        eMasterHealth[HEALTH_RATE][0]               = g_eSettings[SETTING_DEFAULT_HEALTH_RATE][0]
                        eMasterHealth[HEALTH_RATE][1]               = g_eSettings[SETTING_DEFAULT_HEALTH_RATE][1]
                        eMasterHealth[HEALTH_LIMIT]                 = g_eSettings[SETTING_DEFAULT_HEALTH_LIMIT]
                        eMasterHealth[HEALTH_OVERFLOW]              = g_eSettings[SETTING_DEFAULT_HEALTH_OVERFLOW]

                        eMasterLightning[LIGHTNING_SPEED][0]        = g_eSettings[SETTING_DEFAULT_LIGHTNING_SPEED][0]
                        eMasterLightning[LIGHTNING_SPEED][1]        = g_eSettings[SETTING_DEFAULT_LIGHTNING_SPEED][1]

                        eMasterMask[MASK_ALPHA][0]                  = g_eSettings[SETTING_DEFAULT_MASK_ALPHA][0]
                        eMasterMask[MASK_ALPHA][1]                  = g_eSettings[SETTING_DEFAULT_MASK_ALPHA][1]
                        eMasterMask[MASK_FOOTSTEP]                  = g_eSettings[SETTING_DEFAULT_MASK_FOOTSTEP]

                        eMasterMask2[MASK2_MODEL_FLAG]              = g_eSettings[SETTING_DEFAULT_MASK2_MODEL_FLAG]

                        eMasterShield[SHIELD_ARMOR_FREQ][0]         = g_eSettings[SETTING_DEFAULT_SHIELD_ARMOR_FREQ][0]
                        eMasterShield[SHIELD_ARMOR_FREQ][1]         = g_eSettings[SETTING_DEFAULT_SHIELD_ARMOR_FREQ][1]
                        eMasterShield[SHIELD_ARMOR][0]              = g_eSettings[SETTING_DEFAULT_SHIELD_ARMOR][0]
                        eMasterShield[SHIELD_ARMOR][1]              = g_eSettings[SETTING_DEFAULT_SHIELD_ARMOR][1]
                        eMasterShield[SHIELD_ARMOR_LIMIT]           = g_eSettings[SETTING_DEFAULT_SHIELD_ARMOR_LIMIT]
                        eMasterShield[SHIELD_ARMOR_OVERFLOW]        = g_eSettings[SETTING_DEFAULT_SHIELD_ARMOR_OVERFLOW]
                        eMasterShield[SHIELD_ARMOR_TYPE]            = g_eSettings[SETTING_DEFAULT_SHIELD_ARMOR_TYPE]
                        eMasterShield[SHIELD_ABSORB][0]             = g_eSettings[SETTING_DEFAULT_SHIELD_ABSORB]
                        eMasterShield[SHIELD_ABSORB][1]             = g_eSettings[SETTING_DEFAULT_SHIELD_ABSORB]
                        eMasterShield[SHIELD_REFLECT][0]            = g_eSettings[SETTING_DEFAULT_SHIELD_REFLECT]
                        eMasterShield[SHIELD_REFLECT][1]            = g_eSettings[SETTING_DEFAULT_SHIELD_REFLECT]

                        eMasterSkull[SKULL_DAMAGE][0]               = g_eSettings[SETTING_DEFAULT_SKULL_DAMAGE]
                        eMasterSkull[SKULL_DAMAGE][1]               = g_eSettings[SETTING_DEFAULT_SKULL_DAMAGE]
                        eMasterSkull[SKULL_BLOOD][0]                = g_eSettings[SETTING_DEFAULT_SKULL_BLOOD]
                        eMasterSkull[SKULL_BLOOD][1]                = g_eSettings[SETTING_DEFAULT_SKULL_BLOOD]

                        eMasterSkull2[SKULL2_FREQ][0]               = g_eSettings[SETTING_DEFAULT_SKULL2_FREQ][0]
                        eMasterSkull2[SKULL2_FREQ][1]               = g_eSettings[SETTING_DEFAULT_SKULL2_FREQ][1]
                        eMasterSkull2[SKULL2_DAMAGE][0]             = g_eSettings[SETTING_DEFAULT_SKULL2_DAMAGE][0]
                        eMasterSkull2[SKULL2_DAMAGE][1]             = g_eSettings[SETTING_DEFAULT_SKULL2_DAMAGE][1]
                        eMasterSkull2[SKULL2_DAMAGE_TYPE]           = g_eSettings[SETTING_DEFAULT_SKULL2_DAMAGE_TYPE]
                        eMasterSkull2[SKULL2_LIMIT]                 = g_eSettings[SETTING_DEFAULT_SKULL2_LIMIT]
                        eMasterSkull2[SKULL2_OVERFLOW]              = g_eSettings[SETTING_DEFAULT_SKULL2_OVERFLOW]

                        eMasterStun[STUN_FREQ][0]                   = g_eSettings[SETTING_DEFAULT_STUN_FREQ][0]
                        eMasterStun[STUN_FREQ][1]                   = g_eSettings[SETTING_DEFAULT_STUN_FREQ][1]
                        eMasterStun[STUN_AMPLITUDE]                 = g_eSettings[SETTING_DEFAULT_STUN_AMPLITUDE]
                        eMasterStun[STUN_FREQUENCY]                 = g_eSettings[SETTING_DEFAULT_STUN_FREQUENCY]
                        eMasterStun[STUN_COLOR_MIN][0]              = g_eSettings[SETTING_DEFAULT_STUN_COLOR_MIN][0]
                        eMasterStun[STUN_COLOR_MIN][1]              = g_eSettings[SETTING_DEFAULT_STUN_COLOR_MIN][1]
                        eMasterStun[STUN_COLOR_MIN][2]              = g_eSettings[SETTING_DEFAULT_STUN_COLOR_MIN][2]
                        eMasterStun[STUN_COLOR_MIN][3]              = g_eSettings[SETTING_DEFAULT_STUN_COLOR_MIN][3]
                        eMasterStun[STUN_COLOR_MAX][0]              = g_eSettings[SETTING_DEFAULT_STUN_COLOR_MAX][0]
                        eMasterStun[STUN_COLOR_MAX][1]              = g_eSettings[SETTING_DEFAULT_STUN_COLOR_MAX][1]
                        eMasterStun[STUN_COLOR_MAX][2]              = g_eSettings[SETTING_DEFAULT_STUN_COLOR_MAX][2]
                        eMasterStun[STUN_COLOR_MAX][3]              = g_eSettings[SETTING_DEFAULT_STUN_COLOR_MAX][3]
                        eMasterStun[STUN_FOV]                       = g_eSettings[SETTING_DEFAULT_STUN_FOV]

                        eMasterStun2[STUN2_FREQ][0]                 = g_eSettings[SETTING_DEFAULT_STUN2_FREQ][0]
                        eMasterStun2[STUN2_FREQ][1]                 = g_eSettings[SETTING_DEFAULT_STUN2_FREQ][1]
                        eMasterStun2[STUN2_DAMAGE][0]               = g_eSettings[SETTING_DEFAULT_STUN2_DAMAGE][0]
                        eMasterStun2[STUN2_DAMAGE][1]               = g_eSettings[SETTING_DEFAULT_STUN2_DAMAGE][1]
                        eMasterStun2[STUN2_DIRECTION]               = g_eSettings[SETTING_DEFAULT_STUN2_DIRECTION]
                        eMasterStun2[STUN2_KILL]                    = g_eSettings[SETTING_DEFAULT_STUN2_KILL]

                        eMasterUp[UP_JUMP]                          = g_eSettings[SETTING_DEFAULT_UP_JUMP]
                        eMasterUp[UP_GRAVITY][0]                    = g_eSettings[SETTING_DEFAULT_UP_GRAVITY][0]
                        eMasterUp[UP_GRAVITY][1]                    = g_eSettings[SETTING_DEFAULT_UP_GRAVITY][1]

                        eMasterWings[WINGS_NOCLIP]                  = g_eSettings[SETTING_DEFAULT_WINGS_NOCLIP]
                        eMasterWings[WINGS_GODMODE]                 = g_eSettings[SETTING_DEFAULT_WINGS_GODMODE]

                        iSection = SECTION_MASTER
                        g_iMasterConfig ++
                    }
                }
                else
                {
                    LogConfigError(iLine, "Unclosed section name: %s", szData)
                    iSection = SECTION_NONE
                }
            }
            default:
            {
                strtok(szData, szKey, charsmax(szKey), szValue, charsmax(szValue), '=')
                iPos = contain(szValue, "#")
                if ( iPos != -1 )
                    szValue[iPos] = EOS

                trim(szKey)
                trim(szValue)

                switch( iSection )
                {
                    case SECTION_NONE:
                    {
                        LogConfigError(iLine, "Data is not in any defined section: %s", szData)
                    }
                    case SECTION_MAIN_SETTINGS:
                    {
                        strtok(szData, szKey, charsmax(szKey), szValue, charsmax(szValue), '=')
                        iPos = contain(szValue, "#")
                        if ( iPos != -1 )
                            szValue[iPos] = EOS

                        trim(szKey)
                        trim(szValue)

                        if ( equali(szKey, "SETTING_DEFAULT_FLAGS") )
                            parseSetting(DTYPE_FLAGS, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_FLAGS], charsmax(g_eSettings[SETTING_DEFAULT_FLAGS]))
                        else if ( equali(szKey, "SETTING_DEFAULT_TEAM") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_TEAM], charsmax(g_eSettings[SETTING_DEFAULT_TEAM]))
                        else if ( equali(szKey, "SETTING_DEFAULT_ANIM") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_ANIM], charsmax(g_eSettings[SETTING_DEFAULT_ANIM]))
                        else if ( equali(szKey, "SETTING_DEFAULT_ACTIVE_CHANCE") )
                            parseSetting(DTYPE_FLOAT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_ACTIVE_CHANCE], charsmax(g_eSettings[SETTING_DEFAULT_ACTIVE_CHANCE]))
                        else if ( equali(szKey, "SETTING_DEFAULT_ACTIVE_DELAY") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_ACTIVE_DELAY], charsmax(g_eSettings[SETTING_DEFAULT_ACTIVE_DELAY]))
                        else if ( equali(szKey, "SETTING_DEFAULT_ACTIVE_DURATION") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_ACTIVE_DURATION], charsmax(g_eSettings[SETTING_DEFAULT_ACTIVE_DURATION]))
                        else if ( equali(szKey, "SETTING_MASTER_CHECK") )
                            parseSetting(DTYPE_FLOAT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_MASTER_CHECK], charsmax(g_eSettings[SETTING_MASTER_CHECK]))
                        else if ( equali(szKey, "SETTING_DEFAULT_ACTIVE_COOLDOWN") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_ACTIVE_COOLDOWN], charsmax(g_eSettings[SETTING_DEFAULT_ACTIVE_COOLDOWN]))
                        else if ( equali(szKey, "SETTING_DEFAULT_ICON") )
                            parseSetting(DTYPE_STRING_MODEL, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_ICON], charsmax(g_eSettings[SETTING_DEFAULT_ICON]))
                        else if ( equali(szKey, "SETTING_DEFAULT_ICON_SCALE") )
                            parseSetting(DTYPE_FLOAT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_ICON_SCALE], charsmax(g_eSettings[SETTING_DEFAULT_ICON_SCALE]))
                        else if ( equali(szKey, "SETTING_DEFAULT_ICON_ALPHA") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_ICON_ALPHA], charsmax(g_eSettings[SETTING_DEFAULT_ICON_ALPHA]))
                        else if ( equali(szKey, "SETTING_DEFAULT_CLASS") )
                            parseSetting(DTYPE_INT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_CLASS], charsmax(g_eSettings[SETTING_DEFAULT_CLASS]))
                        else if ( equali(szKey, "SETTING_DEFAULT_AMMO_FREQ") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_AMMO_FREQ], charsmax(g_eSettings[SETTING_DEFAULT_AMMO_FREQ]))
                        else if ( equali(szKey, "SETTING_DEFAULT_AMMO_CLIP") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_AMMO_CLIP], charsmax(g_eSettings[SETTING_DEFAULT_AMMO_CLIP]))
                        else if ( equali(szKey, "SETTING_DEFAULT_AMMO_AMMO") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_AMMO_AMMO], charsmax(g_eSettings[SETTING_DEFAULT_AMMO_AMMO]))
                        else if ( equali(szKey, "SETTING_DEFAULT_AMMO_MODE") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_AMMO_MODE], charsmax(g_eSettings[SETTING_DEFAULT_AMMO_MODE]))
                        else if ( equali(szKey, "SETTING_DEFAULT_AMMO_OVERFLOW") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_AMMO_OVERFLOW], charsmax(g_eSettings[SETTING_DEFAULT_AMMO_OVERFLOW]))
                        else if ( equali(szKey, "SETTING_DEFAULT_MASTER_FREQ") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_MASTER_FREQ], charsmax(g_eSettings[SETTING_DEFAULT_MASTER_FREQ]))
                        else if ( equali(szKey, "SETTING_DEFAULT_MASTER_FB_SUPPLY") )
                            parseSetting(DTYPE_INT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_MASTER_FB_SUPPLY], charsmax(g_eSettings[SETTING_DEFAULT_MASTER_FB_SUPPLY]))
                        else if ( equali(szKey, "SETTING_DEFAULT_MASTER_SMOKE_SUPPLY") )
                            parseSetting(DTYPE_INT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_MASTER_SMOKE_SUPPLY], charsmax(g_eSettings[SETTING_DEFAULT_MASTER_SMOKE_SUPPLY]))
                        else if ( equali(szKey, "SETTING_DEFAULT_MASTER_HE_LIMIT") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_MASTER_HE_LIMIT], charsmax(g_eSettings[SETTING_DEFAULT_MASTER_HE_LIMIT]))
                        else if ( equali(szKey, "SETTING_DEFAULT_MASTER_FB_LIMIT") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_MASTER_FB_LIMIT], charsmax(g_eSettings[SETTING_DEFAULT_MASTER_FB_LIMIT]))
                        else if ( equali(szKey, "SETTING_DEFAULT_MASTER_SMOKE_LIMIT") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_MASTER_SMOKE_LIMIT], charsmax(g_eSettings[SETTING_DEFAULT_MASTER_SMOKE_LIMIT]))
                        else if ( equali(szKey, "SETTING_DEFAULT_MASTER_OVERFLOW") )
                            parseSetting(DTYPE_BOOL, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_MASTER_OVERFLOW], charsmax(g_eSettings[SETTING_DEFAULT_MASTER_OVERFLOW]))
                        else if ( equali(szKey, "SETTING_DEFAULT_CLOCK_RELOAD_SPEED") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_CLOCK_RELOAD_SPEED], charsmax(g_eSettings[SETTING_DEFAULT_CLOCK_RELOAD_SPEED]))
                        else if ( equali(szKey, "SETTING_DEFAULT_CLOCK_ATTACK_SPEED") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_CLOCK_ATTACK_SPEED], charsmax(g_eSettings[SETTING_DEFAULT_CLOCK_ATTACK_SPEED]))
                        else if ( equali(szKey, "SETTING_DEFAULT_CLOCK_DEPLOY_SPEED") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_CLOCK_DEPLOY_SPEED], charsmax(g_eSettings[SETTING_DEFAULT_CLOCK_DEPLOY_SPEED]))
                        else if ( equali(szKey, "SETTING_DEFAULT_CLOCK_RECOIL_SETTING") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_CLOCK_RECOIL_SETTING], charsmax(g_eSettings[SETTING_DEFAULT_CLOCK_RECOIL_SETTING]))
                        else if ( equali(szKey, "SETTING_DEFAULT_HEALTH_FREQ") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_HEALTH_FREQ], charsmax(g_eSettings[SETTING_DEFAULT_HEALTH_FREQ]))
                        else if ( equali(szKey, "SETTING_DEFAULT_HEALTH_RATE") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_HEALTH_RATE], charsmax(g_eSettings[SETTING_DEFAULT_HEALTH_RATE]))
                        else if ( equali(szKey, "SETTING_DEFAULT_HEALTH_LIMIT") )
                            parseSetting(DTYPE_FLOAT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_HEALTH_LIMIT], charsmax(g_eSettings[SETTING_DEFAULT_HEALTH_LIMIT]))
                        else if ( equali(szKey, "SETTING_DEFAULT_HEALTH_OVERFLOW") )
                            parseSetting(DTYPE_BOOL, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_HEALTH_OVERFLOW], charsmax(g_eSettings[SETTING_DEFAULT_HEALTH_OVERFLOW]))
                        else if ( equali(szKey, "SETTING_DEFAULT_LIGHTNING_SPEED") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_LIGHTNING_SPEED], charsmax(g_eSettings[SETTING_DEFAULT_LIGHTNING_SPEED]))
                        else if ( equali(szKey, "SETTING_DEFAULT_MASK_ALPHA") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_MASK_ALPHA], charsmax(g_eSettings[SETTING_DEFAULT_MASK_ALPHA]))
                        else if ( equali(szKey, "SETTING_DEFAULT_MASK_FOOTSTEP") )
                            parseSetting(DTYPE_BOOL, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_MASK_FOOTSTEP], charsmax(g_eSettings[SETTING_DEFAULT_MASK_FOOTSTEP]))
                        else if ( equali(szKey, "SETTING_DEFAULT_MASK2_MODEL_FLAG") )
                            parseSetting(DTYPE_FLAGS, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_MASK2_MODEL_FLAG], charsmax(g_eSettings[SETTING_DEFAULT_MASK2_MODEL_FLAG]))
                        else if ( equali(szKey, "SETTING_DEFAULT_SHIELD_ARMOR_FREQ") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_SHIELD_ARMOR_FREQ], charsmax(g_eSettings[SETTING_DEFAULT_SHIELD_ARMOR_FREQ]))
                        else if ( equali(szKey, "SETTING_DEFAULT_SHIELD_ARMOR") )
                            parseSetting(DTYPE_INT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_SHIELD_ARMOR], charsmax(g_eSettings[SETTING_DEFAULT_SHIELD_ARMOR]))
                        else if ( equali(szKey, "SETTING_DEFAULT_SHIELD_ARMOR_OVERFLOW") )
                            parseSetting(DTYPE_BOOL, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_SHIELD_ARMOR_OVERFLOW], charsmax(g_eSettings[SETTING_DEFAULT_SHIELD_ARMOR_OVERFLOW]))
                        else if ( equali(szKey, "SETTING_DEFAULT_SHIELD_ARMOR_TYPE") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_SHIELD_ARMOR_TYPE], charsmax(g_eSettings[SETTING_DEFAULT_SHIELD_ARMOR_TYPE]))
                        else if ( equali(szKey, "SETTING_DEFAULT_SHIELD_ABSORB") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_SHIELD_ABSORB], charsmax(g_eSettings[SETTING_DEFAULT_SHIELD_ABSORB]))
                        else if ( equali(szKey, "SETTING_DEFAULT_SHIELD_REFLECT") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_SHIELD_REFLECT], charsmax(g_eSettings[SETTING_DEFAULT_SHIELD_REFLECT]))
                        else if ( equali(szKey, "SETTING_DEFAULT_SKULL_DAMAGE") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_SKULL_DAMAGE], charsmax(g_eSettings[SETTING_DEFAULT_SKULL_DAMAGE]))
                        else if ( equali(szKey, "SETTING_DEFAULT_SKULL_BLOOD") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_SKULL_BLOOD], charsmax(g_eSettings[SETTING_DEFAULT_SKULL_BLOOD]))
                        else if ( equali(szKey, "SETTING_DEFAULT_SKULL2_FREQ") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_SKULL2_FREQ], charsmax(g_eSettings[SETTING_DEFAULT_SKULL2_FREQ]))
                        else if ( equali(szKey, "SETTING_DEFAULT_SKULL2_DAMAGE") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_SKULL2_DAMAGE], charsmax(g_eSettings[SETTING_DEFAULT_SKULL2_DAMAGE]))
                        else if ( equali(szKey, "SETTING_DEFAULT_SKULL2_DAMAGE_TYPE") )
                            parseSetting(DTYPE_FLAGS, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_SKULL2_DAMAGE_TYPE], charsmax(g_eSettings[SETTING_DEFAULT_SKULL2_DAMAGE_TYPE]))
                        else if ( equali(szKey, "SETTING_DEFAULT_SKULL2_LIMIT") )
                            parseSetting(DTYPE_FLOAT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_SKULL2_LIMIT], charsmax(g_eSettings[SETTING_DEFAULT_SKULL2_LIMIT]))
                        else if ( equali(szKey, "SETTING_DEFAULT_SKULL2_OVERFLOW") )
                            parseSetting(DTYPE_BOOL, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_SKULL2_OVERFLOW], charsmax(g_eSettings[SETTING_DEFAULT_SKULL2_OVERFLOW]))
                        else if ( equali(szKey, "SETTING_DEFAULT_STUN_FREQ") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_STUN_FREQ], charsmax(g_eSettings[SETTING_DEFAULT_STUN_FREQ]))
                        else if ( equali(szKey, "SETTING_DEFAULT_STUN_AMPLITUDE") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_STUN_AMPLITUDE], charsmax(g_eSettings[SETTING_DEFAULT_STUN_AMPLITUDE]))
                        else if ( equali(szKey, "SETTING_DEFAULT_STUN_FREQUENCY") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_STUN_FREQUENCY], charsmax(g_eSettings[SETTING_DEFAULT_STUN_FREQUENCY]))
                        else if ( equali(szKey, "SETTING_DEFAULT_STUN_COLOR_MIN") )
                            parseSetting(DTYPE_VECTOR_4, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_STUN_COLOR_MIN], charsmax(g_eSettings[SETTING_DEFAULT_STUN_COLOR_MIN]))
                        else if ( equali(szKey, "SETTING_DEFAULT_STUN_COLOR_MAX") )
                            parseSetting(DTYPE_VECTOR_4, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_STUN_COLOR_MAX], charsmax(g_eSettings[SETTING_DEFAULT_STUN_COLOR_MAX]))
                        else if ( equali(szKey, "SETTING_DEFAULT_STUN_FOV") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_STUN_FOV], charsmax(g_eSettings[SETTING_DEFAULT_STUN_FOV]))
                        else if ( equali(szKey, "SETTING_DEFAULT_STUN2_FREQ") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_STUN2_FREQ], charsmax(g_eSettings[SETTING_DEFAULT_STUN2_FREQ]))
                        else if ( equali(szKey, "SETTING_DEFAULT_STUN2_DAMAGE") )
                            parseSetting(DTYPE_INT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_STUN2_DAMAGE], charsmax(g_eSettings[SETTING_DEFAULT_STUN2_DAMAGE]))
                        else if ( equali(szKey, "SETTING_DEFAULT_STUN2_DIRECTION") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_STUN2_DIRECTION], charsmax(g_eSettings[SETTING_DEFAULT_STUN2_DIRECTION]))
                        else if ( equali(szKey, "SETTING_DEFAULT_STUN2_KILL") )
                            parseSetting(DTYPE_BOOL, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_STUN2_KILL], charsmax(g_eSettings[SETTING_DEFAULT_STUN2_KILL]))
                        else if ( equali(szKey, "SETTING_DEFAULT_UP_JUMP") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_UP_JUMP], charsmax(g_eSettings[SETTING_DEFAULT_UP_JUMP]))
                        else if ( equali(szKey, "SETTING_DEFAULT_UP_GRAVITY") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_UP_GRAVITY], charsmax(g_eSettings[SETTING_DEFAULT_UP_GRAVITY]))
                        else if ( equali(szKey, "SETTING_DEFAULT_WINGS_NOCLIP") )
                            parseSetting(DTYPE_BOOL, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_WINGS_NOCLIP], charsmax(g_eSettings[SETTING_DEFAULT_WINGS_NOCLIP]))
                        else if ( equali(szKey, "SETTING_DEFAULT_WINGS_GODMODE") )
                            parseSetting(DTYPE_BOOL, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_DEFAULT_WINGS_GODMODE], charsmax(g_eSettings[SETTING_DEFAULT_WINGS_GODMODE]))
                        else if ( equali(szKey, "SETTING_MASTER_LOAD") )
                            parseSetting(DTYPE_BOOL, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_MASTER_LOAD], charsmax(g_eSettings[SETTING_MASTER_LOAD]))
                        else if ( equali(szKey, "SETTING_MASTER_DEFAULT") )
                            parseSetting(DTYPE_BOOL, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_MASTER_DEFAULT], charsmax(g_eSettings[SETTING_MASTER_DEFAULT]))
                        else if ( equali(szKey, "SETTING_OFFSET_BASE") )
                            parseSetting(DTYPE_FLOAT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_OFFSET_BASE], charsmax(g_eSettings[SETTING_OFFSET_BASE]))
                        else if ( equali(szKey, "SETTING_OFFSET") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_OFFSET], charsmax(g_eSettings[SETTING_OFFSET]))
                        else if ( equali(szKey, "SETTING_OFFSET_STEP") )
                            parseSetting(DTYPE_FLOAT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_OFFSET_STEP], charsmax(g_eSettings[SETTING_OFFSET_STEP]))
                        else if ( equali(szKey, "SETTING_ALPHA_INACTIVE") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_ALPHA_INACTIVE], charsmax(g_eSettings[SETTING_ALPHA_INACTIVE]))
                        else if ( equali(szKey, "SETTING_SIZE_BASE") )
                            parseSetting(DTYPE_FLOAT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_SIZE_BASE], charsmax(g_eSettings[SETTING_SIZE_BASE]))
                        else if ( equali(szKey, "SETTING_SIZE_HEIGHT") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_SIZE_HEIGHT], charsmax(g_eSettings[SETTING_SIZE_HEIGHT]))
                        else if ( equali(szKey, "SETTING_SIZE_WIDTH") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_SIZE_WIDTH], charsmax(g_eSettings[SETTING_SIZE_WIDTH]))
                        else if ( equali(szKey, "SETTING_SIZE_DEPTH") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_SIZE_DEPTH], charsmax(g_eSettings[SETTING_SIZE_DEPTH]))
                        else if ( equali(szKey, "SETTING_SOUND_MENU_NAV") )
                            parseSetting(DTYPE_STRING_SOUND, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_SOUND_MENU_NAV], charsmax(g_eSettings[SETTING_SOUND_MENU_NAV]))
                        else if ( equali(szKey, "SETTING_SOUND_MENU_REMOVE") )
                            parseSetting(DTYPE_STRING_SOUND, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_SOUND_MENU_REMOVE], charsmax(g_eSettings[SETTING_SOUND_MENU_REMOVE]))
                        else if ( equali(szKey, "SETTING_SOUND_MENU_ALERT") )
                            parseSetting(DTYPE_STRING_SOUND, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_SOUND_MENU_ALERT], charsmax(g_eSettings[SETTING_SOUND_MENU_ALERT]))
                        else if ( equali(szKey, "SETTING_SOUND_SUITCHARGE") )
                            parseSetting(DTYPE_STRING_SOUND, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_SOUND_SUITCHARGE], charsmax(g_eSettings[SETTING_SOUND_SUITCHARGE]))
                        else if ( equali(szKey, "SETTING_SOUND_BLIP2") )
                            parseSetting(DTYPE_STRING_SOUND, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_SOUND_BLIP2], charsmax(g_eSettings[SETTING_SOUND_BLIP2]))
                        else if ( equali(szKey, "SETTING_SOUND_CLIP1") )
                            parseSetting(DTYPE_STRING_SOUND, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_SOUND_CLIP1], charsmax(g_eSettings[SETTING_SOUND_CLIP1]))
                        else if ( equali(szKey, "SETTING_BEAM") )
                            parseSetting(DTYPE_STRING_SPRITE, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_BEAM], charsmax(g_eSettings[SETTING_BEAM]))
                        else if ( equali(szKey, "SETTING_BEAM_WIDTH") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_BEAM_WIDTH], charsmax(g_eSettings[SETTING_BEAM_WIDTH]))
                        else if ( equali(szKey, "SETTING_BEAM_ALPHA") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_BEAM_ALPHA], charsmax(g_eSettings[SETTING_BEAM_ALPHA]))
                        else if ( equali(szKey, "SETTING_COLOR_ACTIVE") )
                            parseSetting(DTYPE_VECTOR, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_COLOR_ACTIVE], charsmax(g_eSettings[SETTING_COLOR_ACTIVE]))
                        else if ( equali(szKey, "SETTING_COLOR_INACTIVE") )
                            parseSetting(DTYPE_VECTOR, szKey, charsmax(szKey), szValue, charsmax(szValue), g_eSettings[SETTING_COLOR_INACTIVE], charsmax(g_eSettings[SETTING_COLOR_INACTIVE]))
                    }
                    case SECTION_MASTER:
                    {
                        if ( equali(szKey, "MASTER_FLAGS") )
                            parseSetting(DTYPE_FLAGS, szKey, charsmax(szKey), szValue, charsmax(szValue), eMaster[MASTER_FLAGS], charsmax(eMaster[MASTER_FLAGS]), g_eSettings[SETTING_DEFAULT_FLAGS])
                        else if ( equali(szKey, "MASTER_TEAM") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), eMaster[MASTER_TEAM], charsmax(eMaster[MASTER_TEAM]), g_eSettings[SETTING_DEFAULT_TEAM])
                        else if ( equali(szKey, "MASTER_ANIM") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), eMaster[MASTER_ANIM], charsmax(eMaster[MASTER_ANIM]), g_eSettings[SETTING_DEFAULT_ANIM])
                        else if ( equali(szKey, "MASTER_ACTIVE_CHANCE") )
                            parseSetting(DTYPE_FLOAT, szKey, charsmax(szKey), szValue, charsmax(szValue), eMaster[MASTER_ACTIVE_CHANCE], charsmax(eMaster[MASTER_ACTIVE_CHANCE]), g_eSettings[SETTING_DEFAULT_ACTIVE_CHANCE])
                        else if ( equali(szKey, "MASTER_ACTIVE_DELAY") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMaster[MASTER_ACTIVE_DELAY], charsmax(eMaster[MASTER_ACTIVE_DELAY]), g_eSettings[SETTING_DEFAULT_ACTIVE_DELAY])
                        else if ( equali(szKey, "MASTER_ACTIVE_DURATION") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMaster[MASTER_ACTIVE_DURATION], charsmax(eMaster[MASTER_ACTIVE_DURATION]), g_eSettings[SETTING_DEFAULT_ACTIVE_DURATION])
                        else if ( equali(szKey, "MASTER_ACTIVE_COOLDOWN") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMaster[MASTER_ACTIVE_COOLDOWN], charsmax(eMaster[MASTER_ACTIVE_COOLDOWN]), g_eSettings[SETTING_DEFAULT_ACTIVE_COOLDOWN])
                        else if ( equali(szKey, "MASTER_ICON") )
                            parseSetting(DTYPE_STRING_MODEL, szKey, charsmax(szKey), szValue, charsmax(szValue), eMaster[MASTER_ICON], charsmax(eMaster[MASTER_ICON]), g_eSettings[SETTING_DEFAULT_ICON])
                        else if ( equali(szKey, "MASTER_ICON_SCALE") )
                            parseSetting(DTYPE_FLOAT, szKey, charsmax(szKey), szValue, charsmax(szValue), eMaster[MASTER_ICON_SCALE], charsmax(eMaster[MASTER_ICON_SCALE]), g_eSettings[SETTING_DEFAULT_ICON_SCALE])
                        else if ( equali(szKey, "MASTER_ICON_ALPHA") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), eMaster[MASTER_ICON_ALPHA], charsmax(eMaster[MASTER_ICON_ALPHA]), g_eSettings[SETTING_DEFAULT_ICON_ALPHA])
                        else if ( equali(szKey, "MASTER_CLASS") )
                        {
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), eMaster[MASTER_CLASS], charsmax(eMaster[MASTER_CLASS]), g_eSettings[SETTING_DEFAULT_CLASS])

                            switch( eMaster[MASTER_CLASS] )
                            {
                                case CLASS_AMMO:        { eMaster[MASTER_DATA] = ArrayCreate(MASTER_AMMO);         ArrayPushArray(eMaster[MASTER_DATA], eMasterAmmo);         iSection = SECTION_MASTER_AMMO; }
                                case CLASS_BOMB:        { eMaster[MASTER_DATA] = ArrayCreate(MASTER_BOMB);         ArrayPushArray(eMaster[MASTER_DATA], eMasterBomb);         iSection = SECTION_MASTER_BOMB; }
                                case CLASS_CLOCK:       { eMaster[MASTER_DATA] = ArrayCreate(MASTER_CLOCK);        ArrayPushArray(eMaster[MASTER_DATA], eMasterClock);        iSection = SECTION_MASTER_CLOCK; }
                                case CLASS_HEALTH:      { eMaster[MASTER_DATA] = ArrayCreate(MASTER_HEALTH);       ArrayPushArray(eMaster[MASTER_DATA], eMasterHealth);       iSection = SECTION_MASTER_HEALTH; }
                                case CLASS_LIGHTNING:   { eMaster[MASTER_DATA] = ArrayCreate(MASTER_LIGHTNING);    ArrayPushArray(eMaster[MASTER_DATA], eMasterLightning);    iSection = SECTION_MASTER_LIGHTNING; }
                                case CLASS_MASK:        { eMaster[MASTER_DATA] = ArrayCreate(MASTER_MASK);         ArrayPushArray(eMaster[MASTER_DATA], eMasterMask);         iSection = SECTION_MASTER_MASK; }
                                case CLASS_MASK2:       { eMaster[MASTER_DATA] = ArrayCreate(MASTER_MASK2);        ArrayPushArray(eMaster[MASTER_DATA], eMasterMask2);        iSection = SECTION_MASTER_MASK2; }
                                case CLASS_SHIELD:      { eMaster[MASTER_DATA] = ArrayCreate(MASTER_SHIELD);       ArrayPushArray(eMaster[MASTER_DATA], eMasterShield);       iSection = SECTION_MASTER_SHIELD; }
                                case CLASS_SKULL:       { eMaster[MASTER_DATA] = ArrayCreate(MASTER_SKULL);        ArrayPushArray(eMaster[MASTER_DATA], eMasterSkull);        iSection = SECTION_MASTER_SKULL; }
                                case CLASS_SKULL2:      { eMaster[MASTER_DATA] = ArrayCreate(MASTER_SKULL2);       ArrayPushArray(eMaster[MASTER_DATA], eMasterSkull2);       iSection = SECTION_MASTER_SKULL2; }
                                case CLASS_STUN:        { eMaster[MASTER_DATA] = ArrayCreate(MASTER_STUN);         ArrayPushArray(eMaster[MASTER_DATA], eMasterStun);         iSection = SECTION_MASTER_STUN; }
                                case CLASS_STUN2:       { eMaster[MASTER_DATA] = ArrayCreate(MASTER_STUN2);        ArrayPushArray(eMaster[MASTER_DATA], eMasterStun2);        iSection = SECTION_MASTER_STUN2; }
                                case CLASS_UP:          { eMaster[MASTER_DATA] = ArrayCreate(MASTER_UP);           ArrayPushArray(eMaster[MASTER_DATA], eMasterUp);           iSection = SECTION_MASTER_UP; }
                                case CLASS_WINGS:       { eMaster[MASTER_DATA] = ArrayCreate(MASTER_WINGS);        ArrayPushArray(eMaster[MASTER_DATA], eMasterWings);        iSection = SECTION_MASTER_WINGS; }
                            }
                        }
                    }
                    case SECTION_MASTER_AMMO:
                    {
                        if ( equali(szKey, "AMMO_FREQ") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterAmmo[AMMO_FREQ], charsmax(eMasterAmmo[AMMO_FREQ]), g_eSettings[SETTING_DEFAULT_AMMO_FREQ])
                        else if ( equali(szKey, "AMMO_CLIP") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterAmmo[AMMO_CLIP], charsmax(eMasterAmmo[AMMO_CLIP]), g_eSettings[SETTING_DEFAULT_AMMO_CLIP])
                        else if ( equali(szKey, "AMMO_AMMO") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterAmmo[AMMO_AMMO], charsmax(eMasterAmmo[AMMO_AMMO]), g_eSettings[SETTING_DEFAULT_AMMO_AMMO])
                        else if ( equali(szKey, "AMMO_MODE") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterAmmo[AMMO_MODE], charsmax(eMasterAmmo[AMMO_MODE]), g_eSettings[SETTING_DEFAULT_AMMO_MODE])
                        else if ( equali(szKey, "AMMO_OVERFLOW") )
                            parseSetting(DTYPE_BOOL, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterAmmo[AMMO_OVERFLOW], charsmax(eMasterAmmo[AMMO_OVERFLOW]), g_eSettings[SETTING_DEFAULT_AMMO_OVERFLOW])

                        ArraySetArray(eMaster[MASTER_DATA], 0, eMasterAmmo)
                    }
                    case SECTION_MASTER_BOMB:
                    {
                        if ( equali(szKey, "MASTER_FREQ") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterBomb[MASTER_FREQ], charsmax(eMasterBomb[MASTER_FREQ]), g_eSettings[SETTING_DEFAULT_MASTER_FREQ])
                        else if ( equali(szKey, "MASTER_HE_SUPPLY") )
                            parseSetting(DTYPE_INT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterBomb[MASTER_HE_SUPPLY], charsmax(eMasterBomb[MASTER_HE_SUPPLY]), g_eSettings[SETTING_DEFAULT_MASTER_HE_SUPPLY])
                        else if ( equali(szKey, "MASTER_FB_SUPPLY") )
                            parseSetting(DTYPE_INT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterBomb[MASTER_FB_SUPPLY], charsmax(eMasterBomb[MASTER_FB_SUPPLY]), g_eSettings[SETTING_DEFAULT_MASTER_FB_SUPPLY])
                        else if ( equali(szKey, "MASTER_SMOKE_SUPPLY") )
                            parseSetting(DTYPE_INT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterBomb[MASTER_SMOKE_SUPPLY], charsmax(eMasterBomb[MASTER_SMOKE_SUPPLY]), g_eSettings[SETTING_DEFAULT_MASTER_SMOKE_SUPPLY])
                        else if ( equali(szKey, "MASTER_HE_LIMIT") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterBomb[MASTER_HE_LIMIT], charsmax(eMasterBomb[MASTER_HE_LIMIT]), g_eSettings[SETTING_DEFAULT_MASTER_HE_LIMIT])
                        else if ( equali(szKey, "MASTER_FB_LIMIT") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterBomb[MASTER_FB_LIMIT], charsmax(eMasterBomb[MASTER_FB_LIMIT]), g_eSettings[SETTING_DEFAULT_MASTER_FB_LIMIT])
                        else if ( equali(szKey, "MASTER_SMOKE_LIMIT") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterBomb[MASTER_SMOKE_LIMIT], charsmax(eMasterBomb[MASTER_SMOKE_LIMIT]), g_eSettings[SETTING_DEFAULT_MASTER_SMOKE_LIMIT])
                        else if ( equali(szKey, "MASTER_OVERFLOW") )
                            parseSetting(DTYPE_BOOL, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterBomb[MASTER_OVERFLOW], charsmax(eMasterBomb[MASTER_OVERFLOW]), g_eSettings[SETTING_DEFAULT_MASTER_OVERFLOW])

                        ArraySetArray(eMaster[MASTER_DATA], 0, eMasterBomb)
                    }
                    case SECTION_MASTER_CLOCK:
                    {
                        if ( equali(szKey, "CLOCK_RELOAD_SPEED") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterClock[CLOCK_RELOAD_SPEED], charsmax(eMasterClock[CLOCK_RELOAD_SPEED]), g_eSettings[SETTING_DEFAULT_CLOCK_RELOAD_SPEED])
                        else if ( equali(szKey, "CLOCK_ATTACK_SPEED") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterClock[CLOCK_ATTACK_SPEED], charsmax(eMasterClock[CLOCK_ATTACK_SPEED]), g_eSettings[SETTING_DEFAULT_CLOCK_ATTACK_SPEED])
                        else if ( equali(szKey, "CLOCK_DEPLOY_SPEED") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterClock[CLOCK_DEPLOY_SPEED], charsmax(eMasterClock[CLOCK_DEPLOY_SPEED]), g_eSettings[SETTING_DEFAULT_CLOCK_DEPLOY_SPEED])
                        else if ( equali(szKey, "CLOCK_RECOIL_SETTING") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterClock[CLOCK_RECOIL_SETTING], charsmax(eMasterClock[CLOCK_RECOIL_SETTING]), g_eSettings[SETTING_DEFAULT_CLOCK_RECOIL_SETTING])

                        ArraySetArray(eMaster[MASTER_DATA], 0, eMasterClock)
                    }
                    case SECTION_MASTER_HEALTH:
                    {
                        if ( equali(szKey, "HEALTH_FREQ") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterHealth[HEALTH_FREQ], charsmax(eMasterHealth[HEALTH_FREQ]), g_eSettings[SETTING_DEFAULT_HEALTH_FREQ])
                        if ( equali(szKey, "HEALTH_RATE") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterHealth[HEALTH_RATE], charsmax(eMasterHealth[HEALTH_RATE]), g_eSettings[SETTING_DEFAULT_HEALTH_RATE])
                        else if ( equali(szKey, "HEALTH_LIMIT") )
                            parseSetting(DTYPE_FLOAT, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterHealth[HEALTH_LIMIT], charsmax(eMasterHealth[HEALTH_LIMIT]), g_eSettings[SETTING_DEFAULT_HEALTH_LIMIT])
                        else if ( equali(szKey, "HEALTH_OVERFLOW") )
                            parseSetting(DTYPE_BOOL, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterHealth[HEALTH_OVERFLOW], charsmax(eMasterHealth[HEALTH_OVERFLOW]), g_eSettings[SETTING_DEFAULT_HEALTH_OVERFLOW])

                        ArraySetArray(eMaster[MASTER_DATA], 0, eMasterHealth)
                    }
                    case SECTION_MASTER_LIGHTNING:
                    {
                        if ( equali(szKey, "LIGHTNING_SPEED") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterLightning[LIGHTNING_SPEED], charsmax(eMasterLightning[LIGHTNING_SPEED]), g_eSettings[SETTING_DEFAULT_LIGHTNING_SPEED])

                        ArraySetArray(eMaster[MASTER_DATA], 0, eMasterLightning)
                    }
                    case SECTION_MASTER_MASK:
                    {
                        if ( equali(szKey, "MASK_ALPHA") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterMask[MASK_ALPHA], charsmax(eMasterMask[MASK_ALPHA]), g_eSettings[SETTING_DEFAULT_MASK_ALPHA])
                        else if ( equali(szKey, "MASK_FOOTSTEP") )
                            parseSetting(DTYPE_BOOL, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterMask[MASK_FOOTSTEP], charsmax(eMasterMask[MASK_FOOTSTEP]), g_eSettings[SETTING_DEFAULT_MASK_FOOTSTEP])

                        ArraySetArray(eMaster[MASTER_DATA], 0, eMasterMask)
                    }
                    case SECTION_MASTER_MASK2:
                    {
                        if ( equali(szKey, "MASK2_MODEL_FLAG") )
                            parseSetting(DTYPE_FLAGS, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterMask2[MASK2_MODEL_FLAG], charsmax(eMasterMask2[MASK2_MODEL_FLAG]), g_eSettings[SETTING_DEFAULT_MASK2_MODEL_FLAG])

                        ArraySetArray(eMaster[MASTER_DATA], 0, eMasterMask2)
                    }
                    case SECTION_MASTER_SHIELD:
                    {
                        if ( equali(szKey, "SHIELD_ARMOR_FREQ") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterShield[SHIELD_ARMOR_FREQ], charsmax(eMasterShield[SHIELD_ARMOR_FREQ]), g_eSettings[SETTING_DEFAULT_SHIELD_ARMOR_FREQ])
                        if ( equali(szKey, "SHIELD_ARMOR") )
                            parseSetting(DTYPE_INT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterShield[SHIELD_ARMOR], charsmax(eMasterShield[SHIELD_ARMOR]), g_eSettings[SETTING_DEFAULT_SHIELD_ARMOR])
                        else if ( equali(szKey, "SHIELD_ARMOR_LIMIT") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterShield[SHIELD_ARMOR_LIMIT], charsmax(eMasterShield[SHIELD_ARMOR_LIMIT]), g_eSettings[SETTING_DEFAULT_SHIELD_ARMOR_LIMIT])
                        else if ( equali(szKey, "SHIELD_ARMOR_OVERFLOW") )
                            parseSetting(DTYPE_BOOL, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterShield[SHIELD_ARMOR_OVERFLOW], charsmax(eMasterShield[SHIELD_ARMOR_OVERFLOW]), g_eSettings[SETTING_DEFAULT_SHIELD_ARMOR_OVERFLOW])
                        else if ( equali(szKey, "SHIELD_ARMOR_TYPE") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterShield[SHIELD_ARMOR_TYPE], charsmax(eMasterShield[SHIELD_ARMOR_TYPE]), g_eSettings[SETTING_DEFAULT_SHIELD_ARMOR_TYPE])
                        else if ( equali(szKey, "SHIELD_ABSORB") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterShield[SHIELD_ABSORB], charsmax(eMasterShield[SHIELD_ABSORB]), g_eSettings[SETTING_DEFAULT_SHIELD_ABSORB])
                        else if ( equali(szKey, "SHIELD_REFLECT") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterShield[SHIELD_REFLECT], charsmax(eMasterShield[SHIELD_REFLECT]), g_eSettings[SETTING_DEFAULT_SHIELD_REFLECT])

                        ArraySetArray(eMaster[MASTER_DATA], 0, eMasterShield)
                    }
                    case SECTION_MASTER_SKULL:
                    {
                        if ( equali(szKey, "SKULL_DAMAGE") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterShield[SKULL_DAMAGE], charsmax(eMasterShield[SKULL_DAMAGE]), g_eSettings[SETTING_DEFAULT_SKULL_DAMAGE])
                        else if ( equali(szKey, "SKULL_BLOOD") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterShield[SKULL_BLOOD], charsmax(eMasterShield[SKULL_BLOOD]), g_eSettings[SETTING_DEFAULT_SKULL_BLOOD])

                        ArraySetArray(eMaster[MASTER_DATA], 0, eMasterSkull)
                    }
                    case SECTION_MASTER_SKULL2:
                    {
                        if ( equali(szKey, "SKULL2_FREQ") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterSkull2[SKULL2_FREQ], charsmax(eMasterSkull2[SKULL2_FREQ]), g_eSettings[SETTING_DEFAULT_SKULL2_FREQ])
                        else if ( equali(szKey, "SKULL2_DAMAGE") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterSkull2[SKULL2_DAMAGE], charsmax(eMasterSkull2[SKULL2_DAMAGE]), g_eSettings[SETTING_DEFAULT_SKULL2_DAMAGE])
                        else if ( equali(szKey, "SKULL2_DAMAGE_TYPE") )
                            parseSetting(DTYPE_FLAGS, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterSkull2[SKULL2_DAMAGE_TYPE], charsmax(eMasterSkull2[SKULL2_DAMAGE_TYPE]), g_eSettings[SETTING_DEFAULT_SKULL2_DAMAGE_TYPE])
                        else if ( equali(szKey, "SKULL2_LIMIT") )
                            parseSetting(DTYPE_FLOAT, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterSkull2[SKULL2_LIMIT], charsmax(eMasterSkull2[SKULL2_LIMIT]), g_eSettings[SETTING_DEFAULT_SKULL2_LIMIT])
                        else if ( equali(szKey, "SKULL2_OVERFLOW") )
                            parseSetting(DTYPE_BOOL, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterSkull2[SKULL2_OVERFLOW], charsmax(eMasterSkull2[SKULL2_OVERFLOW]), g_eSettings[SETTING_DEFAULT_SKULL2_OVERFLOW])

                        ArraySetArray(eMaster[MASTER_DATA], 0, eMasterSkull2)
                    }
                    case SECTION_MASTER_STUN:
                    {
                        if ( equali(szKey, "STUN_FREQ") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterStun[STUN_FREQ], charsmax(eMasterStun[STUN_FREQ]), g_eSettings[SETTING_DEFAULT_STUN_FREQ])
                        else if ( equali(szKey, "STUN_AMPLITUDE") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterStun[STUN_AMPLITUDE], charsmax(eMasterStun[STUN_AMPLITUDE]), g_eSettings[SETTING_DEFAULT_STUN_AMPLITUDE])
                        else if ( equali(szKey, "STUN_FREQUENCY") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterStun[STUN_FREQUENCY], charsmax(eMasterStun[STUN_FREQUENCY]), g_eSettings[SETTING_DEFAULT_STUN_FREQUENCY])
                        else if ( equali(szKey, "STUN_COLOR_MIN") )
                            parseSetting(DTYPE_VECTOR_4, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterStun[STUN_COLOR_MIN], charsmax(eMasterStun[STUN_COLOR_MIN]), g_eSettings[SETTING_DEFAULT_STUN_COLOR_MIN])
                        else if ( equali(szKey, "STUN_COLOR_MAX") )
                            parseSetting(DTYPE_VECTOR_4, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterStun[STUN_COLOR_MAX], charsmax(eMasterStun[STUN_COLOR_MAX]), g_eSettings[SETTING_DEFAULT_STUN_COLOR_MAX])
                        else if ( equali(szKey, "STUN_FOV") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterStun[STUN_FOV], charsmax(eMasterStun[STUN_FOV]), g_eSettings[SETTING_DEFAULT_STUN_FOV])

                        ArraySetArray(eMaster[MASTER_DATA], 0, eMasterStun)
                    }
                    case SECTION_MASTER_STUN2:
                    {
                        if ( equali(szKey, "STUN2_FREQ") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterStun2[STUN2_FREQ], charsmax(eMasterStun2[STUN2_FREQ]), g_eSettings[SETTING_DEFAULT_STUN2_FREQ])
                        else if ( equali(szKey, "STUN2_DAMAGE") )
                            parseSetting(DTYPE_INT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterStun2[STUN2_DAMAGE], charsmax(eMasterStun2[STUN2_DAMAGE]), g_eSettings[SETTING_DEFAULT_STUN2_DAMAGE])
                        else if ( equali(szKey, "STUN2_DIRECTION") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterStun2[STUN2_DIRECTION], charsmax(eMasterStun2[STUN2_DIRECTION]), g_eSettings[SETTING_DEFAULT_STUN2_DIRECTION])
                        else if ( equali(szKey, "STUN2_KILL") )
                            parseSetting(DTYPE_BOOL, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterStun2[STUN2_KILL], charsmax(eMasterStun2[STUN2_KILL]), g_eSettings[SETTING_DEFAULT_STUN2_KILL])

                        ArraySetArray(eMaster[MASTER_DATA], 0, eMasterStun2)
                    }
                    case SECTION_MASTER_UP:
                    {
                        if ( equali(szKey, "UP_JUMP") )
                            parseSetting(DTYPE_INT, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterUp[UP_JUMP], charsmax(eMasterUp[UP_JUMP]), g_eSettings[SETTING_DEFAULT_UP_JUMP])
                        else if ( equali(szKey, "UP_GRAVITY") )
                            parseSetting(DTYPE_FLOAT_RANGE, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterUp[UP_GRAVITY], charsmax(eMasterUp[UP_GRAVITY]), g_eSettings[SETTING_DEFAULT_UP_GRAVITY])

                        ArraySetArray(eMaster[MASTER_DATA], 0, eMasterUp)
                    }
                    case SECTION_MASTER_WINGS:
                    {
                        if ( equali(szKey, "WINGS_NOCLIP") )
                            parseSetting(DTYPE_BOOL, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterWings[WINGS_NOCLIP], charsmax(eMasterWings[WINGS_NOCLIP]), g_eSettings[SETTING_DEFAULT_WINGS_NOCLIP])
                        else if ( equali(szKey, "WINGS_GODMODE") )
                            parseSetting(DTYPE_BOOL, szKey, charsmax(szKey), szValue, charsmax(szValue), eMasterWings[WINGS_GODMODE], charsmax(eMasterWings[WINGS_GODMODE]), g_eSettings[SETTING_DEFAULT_WINGS_GODMODE])

                        ArraySetArray(eMaster[MASTER_DATA], 0, eMasterWings)
                    }
                }
            }
        }
    }

    if ( g_iMasterConfig )
        ArrayPushArray(g_aMasterConfig, eMaster)
    else
        set_fail_state("No Zone Masters were found in the configuration file.")

    g_bFileWasRead = true
    fclose(iFile)
}

public client_authorized(id)
{
    set_task(DELAY_ON_CONNECT, "UpdateData", id)
}

public client_disconnected(id)
{
    new iItem
    if ( g_ePlayerData[id][PDATA_MASTER_GHOST]
    && (iItem = pev(g_ePlayerData[id][PDATA_MASTER_GHOST], MASTER_ARRAY_ITEM)) != -1 )
    {
        masterKill(g_ePlayerData[id][PDATA_MASTER_GHOST])
        masterRemove(iItem)
    }

    g_ePlayerData[id][PDATA_MASTER_GHOST]   = 0
    g_ePlayerData[id][PDATA_MASTER_ACTION]  = false
    g_ePlayerData[id][PDATA_MASTER_MENU]    = 0
}

public UpdateData(id)
{
    g_ePlayerData[id][PDATA_OFFSET] = g_eSettings[SETTING_OFFSET_BASE]
}

public masterInit()
{
    if ( g_eSettings[SETTING_MASTER_LOAD] )
        loadData()
}

public masterMenu(id, iType)
{
    new szData[64], iMenu
    formatex(szData, charsmax(szData), "%L", id, "MASTER_MENU_TITLE", PLUGIN_VERSION)
    iMenu = menu_create(szData, g_szMenuHandler[iType])

    switch( iType )
    {
        case MENU_ROOT:   { menuRoot(id, iMenu); }
        case MENU_CREATE: { menuCreate(id, iMenu);  format(szData, charsmax(szData), "%s^n%L", szData, id, "MASTER_ROOT_CREATE"); }
        case MENU_STATUS: { menuStatus(id, iMenu);  format(szData, charsmax(szData), "%s^n%L", szData, id, "MASTER_ROOT_STATUS"); }
        case MENU_REMOVE: { menuRemove(id, iMenu);  format(szData, charsmax(szData), "%s^n%L", szData, id, "MASTER_ROOT_REMOVE"); }
        case MENU_SCALE:  { menuScale(id, iMenu);   format(szData, charsmax(szData), "%s^n%L", szData, id, "MASTER_ROOT_SCALE"); }
    }

    if ( menu_pages(iMenu) > 1 )
        format(szData, charsmax(szData), "%s^n%L", szData, id, "MASTER_MENU_TITLE_PAGE")

    menu_setprop(iMenu, MPROP_TITLE, szData)
    menu_setprop(iMenu, MPROP_EXIT, MEXIT_ALL)
    menu_setprop(iMenu, MPROP_NUMBER_COLOR, "\r")

    menu_display(id, iMenu)
    return PLUGIN_HANDLED
}

stock menuNav(id, iMenu)
{
    new szItem[64]

    formatex(szItem, charsmax(szItem), "%L", id, "MASTER_NAV_NEXT")
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "MASTER_NAV_BACK")
    menu_additem(iMenu, szItem)

    menu_addblank2(iMenu)
}

public menuRoot(id, iMenu)
{
    new szItem[64]

    formatex(szItem, charsmax(szItem), "%L", id, "MASTER_ROOT_CREATE")
    menu_additem(iMenu, szItem )

    formatex(szItem, charsmax(szItem), "%L", id, "MASTER_ROOT_STATUS")
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "MASTER_ROOT_REMOVE")
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "MASTER_ROOT_SAVE")
    menu_additem(iMenu, szItem)

    menu_addblank2(iMenu)

    formatex(szItem, charsmax(szItem), "%L", id, "MASTER_ROOT_NOCLIP", id, get_user_noclip(id) ? "MASTER_ON" : "MASTER_OFF")
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "MASTER_ROOT_GODMODE", id, get_user_godmode(id) ? "MASTER_ON" : "MASTER_OFF")
    menu_additem(iMenu, szItem)
}

public menuHandlerRoot(id, menu, item)
{
    if ( item == MENU_EXIT )
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    switch( item )
    {
        case ROOT_CREATE:
        {
            if ( g_iMaster >= MAX_ENT )
            {
                client_print_color(id, id, "%L %L", id, "MASTER_CHAT_TAG", id, "MASTER_CHAT_LIMIT", MAX_ENT)
                masterSound(id, SOUND_MENU_REMOVE)
            }
            else
            {
                masterSound(id, SOUND_MENU_NAV)
                masterMenu(id, MENU_CREATE)
            }
        }
        case ROOT_STATUS:
        {
            if ( !g_iMaster )
            {
                client_print_color(id, id, "%L %L", id, "MASTER_CHAT_TAG", id, "MASTER_CHAT_NO_MASTER")
                masterSound(id, SOUND_MENU_REMOVE)
            }
            else
            {
                masterSound(id, SOUND_MENU_NAV)
                masterMenu(id, MENU_STATUS)
            }
        }
        case ROOT_REMOVE:
        {
            if ( !g_iMaster )
            {
                client_print_color(id, id, "%L %L", id, "MASTER_CHAT_TAG", id, "MASTER_CHAT_NO_MASTER")
                masterSound(id, SOUND_MENU_REMOVE)
            }
            else
            {
                masterSound(id, SOUND_MENU_REMOVE)
                masterMenu(id, MENU_REMOVE)
            }
        }
        case ROOT_SAVE:
        {
            saveData(id)
        }
        case ROOT_NOCLIP:
        {
            masterNoClip(id)
        }
        case ROOT_GODMODE:
        {
            masterGodMod(id)
        }
    }

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

public menuCreate(id, iMenu)
{
    new eMaster[MASTER], szItem[64]

    for ( new i = 0; i < g_iMasterConfig; i ++ )
    {
        ArrayGetArray(g_aMasterConfig, i, eMaster)

        copy(szItem, charsmax(szItem), eMaster[MASTER_NAME])
        menu_additem(iMenu, szItem)
    }
}

public menuHandlerCreate(id, menu, item)
{
    if ( item == MENU_EXIT
    || !is_user_alive(id) )
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    masterCreate(id, item)
    masterSound(id, SOUND_MENU_NAV)
    masterMenu(id, MENU_SCALE)

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

public menuStatus(id, iMenu)
{
    new szItem[64], eMaster[MASTER]

    menuNav(id, iMenu)
    ArrayGetArray(g_aMaster, g_ePlayerData[id][PDATA_MASTER_MENU], eMaster)

    formatex(szItem, charsmax(szItem), "%L", id, "MASTER_STATUS_CURRENT",
    g_szStatusColor[eMaster[MASTER_STATUS]], eMaster[MASTER_NAME], id, g_szStatus[eMaster[MASTER_STATUS]])
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "MASTER_STATUS_ALL_ENABLE")
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "MASTER_STATUS_ALL_DISABLE")
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "MASTER_STATUS_ALL_DEFAULT")
    menu_additem(iMenu, szItem)

    g_ePlayerData[id][PDATA_MASTER_ACTION] = true
    eMaster[MASTER_FLAGS] |= FLAG_SELECT
    ArraySetArray(g_aMaster, g_ePlayerData[id][PDATA_MASTER_MENU], eMaster)
}

public menuHandlerStatus(id, menu, item)
{
    new eMaster[MASTER]
    ArrayGetArray(g_aMaster, g_ePlayerData[id][PDATA_MASTER_MENU], eMaster)
    eMaster[MASTER_FLAGS] &= ~FLAG_SELECT
    ArraySetArray(g_aMaster, g_ePlayerData[id][PDATA_MASTER_MENU], eMaster)

    switch( item )
    {
        case STATUS_NEXT:
        {
            if ( g_ePlayerData[id][PDATA_MASTER_MENU] >= g_iMaster - 1 )
                g_ePlayerData[id][PDATA_MASTER_MENU] = 0
            else
                g_ePlayerData[id][PDATA_MASTER_MENU] ++

            masterSound(id, SOUND_MENU_NAV)
            masterMenu(id, MENU_STATUS)
        }
        case STATUS_BACK:
        {
            if ( g_ePlayerData[id][PDATA_MASTER_MENU] <= 0 )
                g_ePlayerData[id][PDATA_MASTER_MENU] = g_iMaster - 1
            else
                g_ePlayerData[id][PDATA_MASTER_MENU] --

            masterSound(id, SOUND_MENU_NAV)
            masterMenu(id, MENU_STATUS)
        }
        case STATUS_CURRENT:
        {
            if ( ++ eMaster[MASTER_STATUS] > STATUS_FORCE_DISABLE )
                eMaster[MASTER_STATUS] = STATUS_DEFAULT

            if ( eMaster[MASTER_STATUS] == STATUS_FORCE_ENABLE )
                eMaster[MASTER_FLAGS] |= FLAG_ACTIVE
            else if ( eMaster[MASTER_STATUS] == STATUS_FORCE_DISABLE )
                eMaster[MASTER_FLAGS] &= ~FLAG_ACTIVE

            client_print_color(id, id, "%L %L", id, "MASTER_CHAT_TAG", id, "MASTER_CHAT_STATUS_CURRENT",
            eMaster[MASTER_NAME], id, g_szStatusChat[eMaster[MASTER_STATUS]])
            ArraySetArray(g_aMaster, g_ePlayerData[id][PDATA_MASTER_MENU], eMaster)

            masterSound(id, SOUND_MENU_NAV)
            masterMenu(id, MENU_STATUS)
        }
        case STATUS_ALL_ENABLE:
        {
            for ( new i = 0; i < g_iMaster; i ++ )
            {
                ArrayGetArray(g_aMaster, i, eMaster)
                eMaster[MASTER_FLAGS] |= FLAG_ACTIVE
                eMaster[MASTER_STATUS] = STATUS_FORCE_ENABLE

                ArraySetArray(g_aMaster, i, eMaster)
            }

            client_print_color(id, id, "%L %L", id, "MASTER_CHAT_TAG", id, "MASTER_CHAT_STATUS_ALL_ENABLED")
            masterSound(id, SOUND_MENU_ALERT)
            masterMenu(id, MENU_STATUS)
        }
        case STATUS_ALL_DISABLE:
        {
            for ( new i = 0; i < g_iMaster; i ++ )
            {
                ArrayGetArray(g_aMaster, i, eMaster)
                eMaster[MASTER_FLAGS] &= ~FLAG_ACTIVE
                eMaster[MASTER_STATUS] = STATUS_FORCE_DISABLE

                ArraySetArray(g_aMaster, i, eMaster)
            }

            client_print_color(id, id, "%L %L", id, "MASTER_CHAT_TAG", id, "MASTER_CHAT_STATUS_ALL_DISABLED")
            masterSound(id, SOUND_MENU_ALERT)
            masterMenu(id, MENU_STATUS)
        }
        case STATUS_ALL_DEFAULT:
        {
            for ( new i = 0; i < g_iMaster; i ++ )
            {
                ArrayGetArray(g_aMaster, i, eMaster)
                eMaster[MASTER_STATUS] = STATUS_DEFAULT
                ArraySetArray(g_aMaster, i, eMaster)
            }

            client_print_color(id, id, "%L %L", id, "MASTER_CHAT_TAG", id, "MASTER_CHAT_STATUS_ALL_DEFAULT")
            masterSound(id, SOUND_MENU_ALERT)
            masterMenu(id, MENU_STATUS)
        }
        default:
        {
            g_ePlayerData[id][PDATA_MASTER_ACTION] = false
            g_ePlayerData[id][PDATA_MASTER_MENU] = 0
        }
    }

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

public menuRemove(id, iMenu)
{
    new eMaster[MASTER], szItem[64]

    ArrayGetArray(g_aMaster, g_ePlayerData[id][PDATA_MASTER_MENU], eMaster)
    menuNav(id, iMenu)

    formatex(szItem, charsmax(szItem), "%L", id, "MASTER_REMOVE_CURRENT",
    g_szStatusColor[eMaster[MASTER_STATUS]], eMaster[MASTER_NAME])
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "MASTER_REMOVE_ALL")
    menu_additem(iMenu, szItem)

    g_ePlayerData[id][PDATA_MASTER_ACTION] = true
    eMaster[MASTER_FLAGS] |= FLAG_SELECT
    ArraySetArray(g_aMaster, g_ePlayerData[id][PDATA_MASTER_MENU], eMaster)
}

public menuHandlerRemove(id, menu, item)
{
    new eMaster[MASTER]

    ArrayGetArray(g_aMaster, g_ePlayerData[id][PDATA_MASTER_MENU], eMaster)
    eMaster[MASTER_FLAGS] &= ~FLAG_SELECT
    ArraySetArray(g_aMaster, g_ePlayerData[id][PDATA_MASTER_MENU], eMaster)

    switch( item )
    {
        case REMOVE_NEXT:
        {
            if ( g_ePlayerData[id][PDATA_MASTER_MENU] >= g_iMaster - 1 )
                g_ePlayerData[id][PDATA_MASTER_MENU] = 0
            else
                g_ePlayerData[id][PDATA_MASTER_MENU] ++

            masterSound(id, SOUND_MENU_NAV)
            masterMenu(id, MENU_REMOVE)
        }
        case REMOVE_BACK:
        {
            if ( g_ePlayerData[id][PDATA_MASTER_MENU] <= 0 )
                g_ePlayerData[id][PDATA_MASTER_MENU] = g_iMaster - 1
            else
                g_ePlayerData[id][PDATA_MASTER_MENU] --

            masterSound(id, SOUND_MENU_NAV)
            masterMenu(id, MENU_REMOVE)
        }
        case REMOVE_CURRENT:
        {
            masterKill(eMaster[MASTER_ICON])
            masterKill(eMaster[MASTER_ID])
            masterRemove(g_ePlayerData[id][PDATA_MASTER_MENU])

            client_print_color(id, id, "%L %L", id, "MASTER_CHAT_TAG", id, "MASTER_CHAT_REMOVE_CURRENT", eMaster[MASTER_NAME])
            g_ePlayerData[id][PDATA_MASTER_MENU] = 0

            masterSound(id, g_iMaster > 0 ? SOUND_MENU_REMOVE : SOUND_MENU_NAV)
            masterMenu(id, g_iMaster > 0 ? MENU_REMOVE : MENU_ROOT)
        }
        case REMOVE_ALL:
        {
            while ( g_iMaster )
            {
                ArrayGetArray(g_aMaster, 0, eMaster)

                masterKill(eMaster[MASTER_ICON])
                masterKill(eMaster[MASTER_ID])
                masterRemove(0)
            }

            client_print_color(0, 0, "%L %L", 0, "MASTER_CHAT_TAG", 0, "MASTER_CHAT_REMOVE_ALL")
            g_ePlayerData[id][PDATA_MASTER_MENU] = 0

            masterSound(id, SOUND_MENU_ALERT)
            masterMenu(id, MENU_REMOVE)
        }
        default:
        {
            g_ePlayerData[id][PDATA_MASTER_ACTION] = false
            g_ePlayerData[id][PDATA_MASTER_MENU] = 0
        }
    }

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

public menuScale(id, iMenu)
{
    new szItem[64]

    formatex(szItem, charsmax(szItem), "%L", id, "MASTER_SCALE_HEIGHT", id, g_ePlayerData[id][PDATA_SCALE_UP] ? "MASTER_ADD" : "MASTER_REMOVE")
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "MASTER_SCALE_WIDTH", id, g_ePlayerData[id][PDATA_SCALE_UP] ? "MASTER_ADD" : "MASTER_REMOVE")
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "MASTER_SCALE_DEPTH", id, g_ePlayerData[id][PDATA_SCALE_UP] ? "MASTER_ADD" : "MASTER_REMOVE")
    menu_additem(iMenu, szItem)

    menu_addblank2(iMenu)

    formatex(szItem, charsmax(szItem), "%L", id, "MASTER_SCALE_FACTOR", g_ePlayerData[id][PDATA_SCALE_UP] ? "\y" : "\r", g_fScaleFactor[g_ePlayerData[id][PDATA_SCALE_FACTOR]])
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "MASTER_SCALE_MODE", id, g_ePlayerData[id][PDATA_SCALE_UP] ? "MASTER_INCREASE" : "MASTER_DECREASE")
    menu_additem(iMenu, szItem)

    formatex(szItem, charsmax(szItem), "%L", id, "MASTER_SCALE_PLACE")
    menu_additem(iMenu, szItem)
}

public menuHandlerScale(id, menu, item)
{
    new eMaster[MASTER], iItem
    if ( (iItem = masterGet(eMaster, g_ePlayerData[id][PDATA_MASTER_GHOST])) == -1 )
    {
        menu_destroy(menu)
        return PLUGIN_HANDLED
    }

    new Float:fCurrentTime
    fCurrentTime = get_gametime()

    switch( item )
    {
        case SCALE_HEIGHT:
        {
            if ( g_ePlayerData[id][PDATA_SCALE_UP] )
            {
                eMaster[MASTER_SCALE][2] += g_fScaleFactor[g_ePlayerData[id][PDATA_SCALE_FACTOR]]
                if (eMaster[MASTER_SCALE][2] > g_eSettings[SETTING_SIZE_HEIGHT][1])
                    eMaster[MASTER_SCALE][2] = g_eSettings[SETTING_SIZE_HEIGHT][1]
            }
            else
            {
                eMaster[MASTER_SCALE][2] -= g_fScaleFactor[g_ePlayerData[id][PDATA_SCALE_FACTOR]]
                if (eMaster[MASTER_SCALE][2] < g_eSettings[SETTING_SIZE_HEIGHT][0])
                    eMaster[MASTER_SCALE][2] = g_eSettings[SETTING_SIZE_HEIGHT][0]
            }

            ArraySetArray(g_aMaster, iItem, eMaster)
            masterSound(id, SOUND_MENU_NAV)
            masterMenu(id, MENU_SCALE)
        }
        case SCALE_WIDTH:
        {
            if ( g_ePlayerData[id][PDATA_SCALE_UP] )
            {
                eMaster[MASTER_SCALE][0] += g_fScaleFactor[g_ePlayerData[id][PDATA_SCALE_FACTOR]]
                if (eMaster[MASTER_SCALE][0] > g_eSettings[SETTING_SIZE_WIDTH][1])
                    eMaster[MASTER_SCALE][0] = g_eSettings[SETTING_SIZE_WIDTH][1]
            }
            else
            {
                eMaster[MASTER_SCALE][0] -= g_fScaleFactor[g_ePlayerData[id][PDATA_SCALE_FACTOR]]
                if (eMaster[MASTER_SCALE][0] < g_eSettings[SETTING_SIZE_WIDTH][0])
                    eMaster[MASTER_SCALE][0] = g_eSettings[SETTING_SIZE_WIDTH][0]
            }

            ArraySetArray(g_aMaster, iItem, eMaster)
            masterSound(id, SOUND_MENU_NAV)
            masterMenu(id, MENU_SCALE)
        }
        case SCALE_DEPTH:
        {
            if ( g_ePlayerData[id][PDATA_SCALE_UP] )
            {
                eMaster[MASTER_SCALE][1] += g_fScaleFactor[g_ePlayerData[id][PDATA_SCALE_FACTOR]]
                if (eMaster[MASTER_SCALE][1] > g_eSettings[SETTING_SIZE_DEPTH][1])
                    eMaster[MASTER_SCALE][1] = g_eSettings[SETTING_SIZE_DEPTH][1]
            }
            else
            {
                eMaster[MASTER_SCALE][1] -= g_fScaleFactor[g_ePlayerData[id][PDATA_SCALE_FACTOR]]
                if (eMaster[MASTER_SCALE][1] < g_eSettings[SETTING_SIZE_DEPTH][0])
                    eMaster[MASTER_SCALE][1] = g_eSettings[SETTING_SIZE_DEPTH][0]
            }

            ArraySetArray(g_aMaster, iItem, eMaster)
            masterSound(id, SOUND_MENU_NAV)
            masterMenu(id, MENU_SCALE)
        }
        case SCALE_FACTOR:
        {
            g_ePlayerData[id][PDATA_SCALE_FACTOR] += 1
            if ( g_ePlayerData[id][PDATA_SCALE_FACTOR] >= sizeof(g_fScaleFactor) )
                g_ePlayerData[id][PDATA_SCALE_FACTOR] = 0

            masterSound(id, SOUND_MENU_NAV)
            masterMenu(id, MENU_SCALE)
        }
        case SCALE_MODE:
        {
            g_ePlayerData[id][PDATA_SCALE_UP] = !g_ePlayerData[id][PDATA_SCALE_UP]

            masterSound(id, SOUND_MENU_NAV)
            masterMenu(id, MENU_SCALE)
        }
        case SCALE_PLACE:
        {
            masterTrace(eMaster, id)
            g_ePlayerData[id][PDATA_MASTER_GHOST] = 0
            g_ePlayerData[id][PDATA_MASTER_ACTION] = false

            if ( eMaster[MASTER_FLAGS] & FLAG_ACTIVE_DELAY )
                eMaster[MASTER_NEXT_ENABLE] = fCurrentTime + random_float(eMaster[MASTER_ACTIVE_DELAY][0], eMaster[MASTER_ACTIVE_DELAY][1])
            else
                eMaster[MASTER_FLAGS] |= FLAG_ACTIVE

            masterSetAnim(eMaster)
            masterSetActive(eMaster)
            ArraySetArray(g_aMaster, iItem, eMaster)

            client_print_color(id, id, "%L %L", id, "MASTER_CHAT_TAG", id, "MASTER_CHAT_CREATE_NEW", eMaster[MASTER_NAME])
            masterSound(id, SOUND_MENU_NAV)
            masterMenu(id, MENU_ROOT)
        }
        default:
        {
            masterKill(eMaster[MASTER_ID])
            masterRemove(iItem)
            g_ePlayerData[id][PDATA_MASTER_GHOST] = 0
            g_ePlayerData[id][PDATA_MASTER_ACTION] = false
        }
    }

    menu_destroy(menu)
    return PLUGIN_HANDLED
}

public masterTask()
{
    static eMaster[MASTER],
    eMasterAmmo[MASTER_AMMO], eMasterBomb[MASTER_BOMB], eMasterClock[MASTER_CLOCK], eMasterHealth[MASTER_HEALTH],
    eMasterLightning[MASTER_LIGHTNING], eMasterMask[MASTER_MASK], eMasterMask2[MASTER_MASK2],
    eMasterShield[MASTER_SHIELD], eMasterSkull[MASTER_SKULL], eMasterSkull2[MASTER_SKULL2],
    eMasterStun[MASTER_STUN], eMasterStun2[MASTER_STUN2], eMasterUp[MASTER_UP], eMasterWings[MASTER_WINGS],
    iWeaponActive, iWeapon, iClip, iAmmo, iNewClip, iNewAmmo,
    iHe, iFb, iSmoke, iNewHe, iNewFb, iNewSmoke, Float:fHealth, Float:fNewHealth,
    Float:fAlpha, iModel[4], iModelCount, iShield, iShieldNew, Float:fDamage,
    iAmplitude, iDuration, iFrequency, iFov, iDamage, iJump, Float:fGravity,
    Float:fOrigin[3], Float:fCurrentTime
    fCurrentTime = get_gametime()

    for ( new id = 1; id <= g_iMaxPlayers; id ++ )
    {
        if ( !is_user_alive(id) )
            continue

        pev(id, pev_origin, fOrigin)
        pev(id, pev_health, fHealth)
        iWeaponActive = cs_get_user_weapon_entity(id)
        iWeapon = cs_get_user_weapon(id, iClip, iAmmo)
        iNewClip = iClip
        iNewAmmo = iAmmo
        iNewHe = iHe = cs_get_user_bpammo(id, CSW_HEGRENADE)
        iNewFb = iFb = cs_get_user_bpammo(id, CSW_FLASHBANG)
        iNewSmoke = iSmoke = cs_get_user_bpammo(id, CSW_SMOKEGRENADE)
        g_ePlayerData[id][PDATA_CLOCK] = false
        g_ePlayerData[id][PDATA_CLOCK_RELOAD_SPEED] = 1.0
        g_ePlayerData[id][PDATA_CLOCK_ATTACK_SPEED] = 1.0
        g_ePlayerData[id][PDATA_CLOCK_DEPLOY_SPEED] = 1.0
        g_ePlayerData[id][PDATA_CLOCK_RECOIL_SETTING] = 1.0
        fNewHealth = fHealth
        g_ePlayerData[id][PDATA_LIGHTNING] = false
        g_ePlayerData[id][PDATA_LIGHTNING_SPEED] = 1.0
        g_ePlayerData[id][PDATA_MASK] = false
        fAlpha = 1.0
        iModelCount = 0
        g_ePlayerData[id][PDATA_MASK2] = false
        g_ePlayerData[id][PDATA_SHIELD] = false
        g_ePlayerData[id][PDATA_SHIELD_ABSORB] = 0.0
        g_ePlayerData[id][PDATA_SHIELD_REFLECT] = 0.0
        iShield = cs_get_user_armor(id)
        iShieldNew = iShield
        g_ePlayerData[id][PDATA_SKULL] = false
        g_ePlayerData[id][PDATA_SKULL_DAMAGE] = 0.0
        g_ePlayerData[id][PDATA_SKULL_BLOOD] = 0.0
        fDamage = 0.0
        g_ePlayerData[id][PDATA_STUN] = false
        iAmplitude = 0
        iFrequency = 0
        iFov = 0
        g_ePlayerData[id][PDATA_STUN2] = false
        iDamage = 0
        g_ePlayerData[id][PDATA_UP] = false
        iJump = 0
        fGravity = 1.0
        g_ePlayerData[id][PDATA_WINGS] = false

        if ( !g_ePlayerData[id][PDATA_MASTER_GHOST] )
        {
            if ( g_ePlayerData[id][PDATA_MASTER_ACTION] )
                masterCheck(id)
        }
        else if ( masterGet(eMaster, g_ePlayerData[id][PDATA_MASTER_GHOST]) != -1 )
        {
            masterTrace(eMaster, id)
        }

        for ( new j = 0; j < g_iMaster; j ++ )
        {
            ArrayGetArray(g_aMaster, j, eMaster)
            if ( !isMasterActive(eMaster, fOrigin, id) )
                continue

            switch( eMaster[MASTER_CLASS] )
            {
                case CLASS_AMMO:
                {
                    if ( (1 << iWeapon) & CSW_ALL_GUNS
                    && fCurrentTime >= g_ePlayerData[id][PDATA_NEXT_AMMO] )
                    {
                        ArrayGetArray(eMaster[MASTER_DATA], 0, eMasterAmmo)

                        iNewClip += eMasterAmmo[AMMO_MODE] == MODE_RELATIVE ? floatround(eMasterAmmo[AMMO_CLIP] * g_iWeaponMaxClip[iWeapon]) : floatround(eMasterAmmo[AMMO_CLIP])
                        if ( !eMasterAmmo[AMMO_OVERFLOW] && iNewClip > g_iWeaponMaxClip[iWeapon] )
                            iNewClip = g_iWeaponMaxClip[iWeapon]

                        iNewAmmo += eMasterAmmo[AMMO_MODE] == MODE_RELATIVE ? floatround(eMasterAmmo[AMMO_AMMO] * g_iWeaponMaxBp[iWeapon]) : floatround(eMasterAmmo[AMMO_AMMO])
                        if ( !eMasterAmmo[AMMO_OVERFLOW] && iNewAmmo > g_iWeaponMaxBp[iWeapon] )
                            iNewAmmo = g_iWeaponMaxBp[iWeapon]
                    }
                }
                case CLASS_BOMB:
                {
                    if ( fCurrentTime >= g_ePlayerData[id][PDATA_NEXT_BOMB] )
                    {
                        ArrayGetArray(eMaster[MASTER_DATA], 0, eMasterBomb)

                        iNewHe += random_num(eMasterBomb[MASTER_HE_SUPPLY][0], eMasterBomb[MASTER_HE_SUPPLY][1])
                        if ( !eMasterBomb[MASTER_OVERFLOW] && iNewHe > eMasterBomb[MASTER_HE_LIMIT] )
                            iNewHe = eMasterBomb[MASTER_HE_LIMIT]

                        iNewFb += random_num(eMasterBomb[MASTER_FB_SUPPLY][0], eMasterBomb[MASTER_FB_SUPPLY][1])
                        if ( !eMasterBomb[MASTER_OVERFLOW] && iNewFb > eMasterBomb[MASTER_FB_LIMIT] )
                            iNewFb = eMasterBomb[MASTER_FB_LIMIT]

                        iNewSmoke += random_num(eMasterBomb[MASTER_SMOKE_SUPPLY][0], eMasterBomb[MASTER_SMOKE_SUPPLY][1])
                        if ( !eMasterBomb[MASTER_OVERFLOW] && iNewSmoke > eMasterBomb[MASTER_SMOKE_LIMIT] )
                            iNewSmoke = eMasterBomb[MASTER_SMOKE_LIMIT]
                    }
                }
                case CLASS_CLOCK:
                {
                    ArrayGetArray(eMaster[MASTER_DATA], 0, eMasterClock)

                    g_ePlayerData[id][PDATA_CLOCK] = true
                    g_ePlayerData[id][PDATA_CLOCK_RELOAD_SPEED] *= random_float(eMasterClock[CLOCK_RELOAD_SPEED][0], eMasterClock[CLOCK_RELOAD_SPEED][1])
                    g_ePlayerData[id][PDATA_CLOCK_ATTACK_SPEED] *= random_float(eMasterClock[CLOCK_ATTACK_SPEED][0], eMasterClock[CLOCK_ATTACK_SPEED][1])
                    g_ePlayerData[id][PDATA_CLOCK_DEPLOY_SPEED] *= random_float(eMasterClock[CLOCK_DEPLOY_SPEED][0], eMasterClock[CLOCK_DEPLOY_SPEED][1])
                    g_ePlayerData[id][PDATA_CLOCK_RECOIL_SETTING] *= random_float(eMasterClock[CLOCK_RECOIL_SETTING][0], eMasterClock[CLOCK_RECOIL_SETTING][1])
                }
                case CLASS_HEALTH:
                {
                    if ( fCurrentTime >= g_ePlayerData[id][PDATA_NEXT_HEALTH] )
                    {
                        ArrayGetArray(eMaster[MASTER_DATA], 0, eMasterHealth)

                        fNewHealth += random_float(eMasterHealth[HEALTH_RATE][0], eMasterHealth[HEALTH_RATE][1])
                        if ( !eMasterHealth[HEALTH_OVERFLOW] && fNewHealth > eMasterHealth[HEALTH_LIMIT] )
                            fNewHealth = eMasterHealth[HEALTH_LIMIT]
                    }
                }
                case CLASS_LIGHTNING:
                {
                    ArrayGetArray(eMaster[MASTER_DATA], 0, eMasterLightning)

                    g_ePlayerData[id][PDATA_LIGHTNING] = true
                    g_ePlayerData[id][PDATA_LIGHTNING_SPEED] *= random_float(eMasterLightning[LIGHTNING_SPEED][0], eMasterLightning[LIGHTNING_SPEED][1])
                }
                case CLASS_MASK:
                {
                    ArrayGetArray(eMaster[MASTER_DATA], 0, eMasterMask)

                    g_ePlayerData[id][PDATA_MASK] = true
                    fAlpha *= random_float(eMasterMask[MASK_ALPHA][0], eMasterMask[MASK_ALPHA][1])
                }
                case CLASS_MASK2:
                {
                    ArrayGetArray(eMaster[MASTER_DATA], 0, eMasterMask2)
                    g_ePlayerData[id][PDATA_MASK2] = true

                    for ( new i = 0; i < 4; i ++ )
                    {
                        if ( eMasterMask2[MASK2_MODEL_FLAG] & (1 << i) )
                            iModel[iModelCount ++] = i
                    }
                }
                case CLASS_SHIELD:
                {
                    ArrayGetArray(eMaster[MASTER_DATA], 0, eMasterShield)
                    g_ePlayerData[id][PDATA_SHIELD] = true
                    g_ePlayerData[id][PDATA_SHIELD_ABSORB] += random_float(eMasterShield[SHIELD_ABSORB][0], eMasterShield[SHIELD_ABSORB][1])
                    g_ePlayerData[id][PDATA_SHIELD_REFLECT] += random_float(eMasterShield[SHIELD_REFLECT][0], eMasterShield[SHIELD_REFLECT][1])

                    if ( fCurrentTime >= g_ePlayerData[id][PDATA_NEXT_SHIELD] )
                    {
                        iShieldNew += random_num(eMasterShield[SHIELD_ARMOR][0], eMasterShield[SHIELD_ARMOR][1])
                        if ( !eMasterShield[SHIELD_ARMOR_OVERFLOW] && iShieldNew > eMasterShield[SHIELD_ARMOR_LIMIT] )
                            iShieldNew = eMasterShield[SHIELD_ARMOR_LIMIT]
                    }
                }
                case CLASS_SKULL:
                {
                    ArrayGetArray(eMaster[MASTER_DATA], 0, eMasterSkull)
                    g_ePlayerData[id][PDATA_SKULL] = true
                    g_ePlayerData[id][PDATA_SKULL_DAMAGE] += random_float(eMasterSkull[SKULL_DAMAGE][0], eMasterSkull[SKULL_DAMAGE][1])
                    g_ePlayerData[id][PDATA_SKULL_BLOOD] += random_float(eMasterSkull[SKULL_BLOOD][0], eMasterSkull[SKULL_BLOOD][1])
                }
                case CLASS_SKULL2:
                {
                    if ( fCurrentTime >= g_ePlayerData[id][PDATA_NEXT_DAMAGE] )
                    {
                        ArrayGetArray(eMaster[MASTER_DATA], 0, eMasterSkull2)

                        fDamage += random_float(eMasterSkull2[SKULL2_DAMAGE][0], eMasterSkull2[SKULL2_DAMAGE][1])
                        if ( !eMasterSkull2[SKULL2_OVERFLOW] && fDamage < eMasterSkull2[SKULL2_LIMIT] )
                            fDamage = eMasterSkull2[SKULL2_LIMIT]
                    }
                }
                case CLASS_STUN:
                {
                    if ( fCurrentTime >= g_ePlayerData[id][PDATA_NEXT_STUN] )
                    {
                        ArrayGetArray(eMaster[MASTER_DATA], 0, eMasterStun)
                        g_ePlayerData[id][PDATA_STUN] = true

                        iAmplitude += eMasterStun[STUN_AMPLITUDE]
                        iDuration = floatround(random_float(eMasterStun[STUN_FREQ][0], eMasterStun[STUN_FREQ][1]))
                        iFrequency += eMasterStun[STUN_FREQUENCY]
                        iFov += eMasterStun[STUN_FOV]
                    }
                }
                case CLASS_STUN2:
                {
                    if ( fCurrentTime >= g_ePlayerData[id][PDATA_NEXT_STUN2] )
                    {
                        ArrayGetArray(eMaster[MASTER_DATA], 0, eMasterStun2)
                        g_ePlayerData[id][PDATA_STUN2] = true

                        iDamage += random_num(eMasterStun2[STUN2_DAMAGE][0], eMasterStun2[STUN2_DAMAGE][1])
                    }
                }
                case CLASS_UP:
                {
                    ArrayGetArray(eMaster[MASTER_DATA], 0, eMasterUp)
                    g_ePlayerData[id][PDATA_UP] = true
                    iJump += eMasterUp[UP_JUMP]
                    fGravity *= random_float(eMasterUp[UP_GRAVITY][0], eMasterUp[UP_GRAVITY][1])
                }
                case CLASS_WINGS:
                {
                    ArrayGetArray(eMaster[MASTER_DATA], 0, eMasterWings)
                    g_ePlayerData[id][PDATA_WINGS] = true
                }
            }
        }

        if ( iNewClip != iClip || iNewAmmo != iAmmo )
        {
            if ( iNewClip != iClip )
            {
                cs_set_weapon_ammo(iWeaponActive, iNewClip)
                ammoPickup(id, iWeaponActive, iNewClip - iClip)
            }

            if ( iNewAmmo != iAmmo )
            {
                cs_set_user_bpammo(id, iWeapon, iNewAmmo)
                ammoPickup(id, iWeaponActive, iNewAmmo - iAmmo)
            }

            masterSound(id, SOUND_CLIP1)
            g_ePlayerData[id][PDATA_NEXT_AMMO] = fCurrentTime + random_float(eMasterAmmo[AMMO_FREQ][0], eMasterAmmo[AMMO_FREQ][1])
        }

        if ( iNewHe != iHe || iNewFb != iFb || iNewSmoke != iSmoke )
        {
            if ( iNewHe != iHe )
            {
                if ( !iHe )  give_item(id, "weapon_hegrenade")
                else         bombPickup(id, CSW_HEGRENADE)

                cs_set_user_bpammo(id, CSW_HEGRENADE, iNewHe)
            }

            if ( iNewFb != iFb )
            {
                if ( !iFb )  give_item(id, "weapon_flashbang")
                else         bombPickup(id, CSW_FLASHBANG)

                cs_set_user_bpammo(id, CSW_FLASHBANG, iNewFb)
            }

            if ( iNewSmoke != iSmoke )
            {
                if ( !iSmoke )  give_item(id, "weapon_smokegrenade")
                else            bombPickup(id, CSW_SMOKEGRENADE)

                cs_set_user_bpammo(id, CSW_SMOKEGRENADE, iNewSmoke)
            }

            masterSound(id, SOUND_CLIP1)
            g_ePlayerData[id][PDATA_NEXT_BOMB] = fCurrentTime + random_float(eMasterBomb[MASTER_FREQ][0], eMasterBomb[MASTER_FREQ][1])
        }

        if ( fHealth != fNewHealth )
        {
            set_pev(id, pev_health, fNewHealth)
            g_ePlayerData[id][PDATA_NEXT_HEALTH] = fCurrentTime + random_float(eMasterHealth[HEALTH_FREQ][0], eMasterHealth[HEALTH_FREQ][1])
        }

        if ( g_ePlayerData[id][PDATA_LIGHTNING] )
        {
            if ( g_ePlayerData[id][PDATA_LIGHTNING_SPEED] != g_ePlayerData[id][PDATA_LIGHTNING_LAST] )
            {
                g_ePlayerData[id][PDATA_LIGHTNING_LAST] = g_ePlayerData[id][PDATA_LIGHTNING_SPEED]
                ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id)
            }
        }
        else if ( g_ePlayerData[id][PDATA_LIGHTNING_LAST] )
        {
            g_ePlayerData[id][PDATA_LIGHTNING_LAST] = 0.0
            ExecuteHamB(Ham_CS_Player_ResetMaxSpeed, id)
        }

        if ( g_ePlayerData[id][PDATA_MASK] )
        {
            if ( pev(id, pev_rendermode) == kRenderNormal )
            {
                set_pev(id, pev_rendermode, kRenderTransAlpha)

                if ( eMasterMask[MASK_FOOTSTEP] )
                    set_user_footsteps(id, 1)
            }

            if ( fAlpha != g_ePlayerData[id][PDATA_MASK_LAST] )
            {
                g_ePlayerData[id][PDATA_MASK_LAST] = fAlpha
                set_pev(id, pev_renderamt, 255.0 * fAlpha)
            }
        }
        else if ( g_ePlayerData[id][PDATA_MASK_LAST] )
        {
            set_pev(id, pev_renderamt, 255.0)
            set_pev(id, pev_rendermode, kRenderNormal)
            g_ePlayerData[id][PDATA_MASK_LAST] = 0.0

            if ( eMasterMask[MASK_FOOTSTEP] )
                set_user_footsteps(id, 0)
        }

        if ( g_ePlayerData[id][PDATA_MASK2] )
        {
            if ( !g_ePlayerData[id][PDATA_MASK2_CHANGE] )
            {
                cs_get_user_model(id, g_ePlayerData[id][PDATA_MASK2_MODEL], charsmax(g_ePlayerData[][PDATA_MASK2_MODEL]))
                g_ePlayerData[id][PDATA_MASK2_CHANGE] = true

                if ( cs_get_user_team(id) == CS_TEAM_T )
                    cs_set_user_model(id, g_szCTModels[iModel[random(iModelCount)]])
                else if ( cs_get_user_team(id) == CS_TEAM_CT )
                    cs_set_user_model(id, g_szTModels[iModel[random(iModelCount)]])
            }
        }
        else if ( g_ePlayerData[id][PDATA_MASK2_CHANGE] )
        {
            cs_set_user_model(id, g_ePlayerData[id][PDATA_MASK2_MODEL])
            g_ePlayerData[id][PDATA_MASK2_CHANGE] = false
        }

        if ( iShield != iShieldNew )
        {
            cs_set_user_armor(id, iShieldNew, CsArmorType:eMasterShield[SHIELD_ARMOR_TYPE])
            g_ePlayerData[id][PDATA_NEXT_SHIELD] = fCurrentTime + random_float(eMasterShield[SHIELD_ARMOR_FREQ][0], eMasterShield[SHIELD_ARMOR_FREQ][1])
        }

        if ( fDamage > 0.0 )
        {
            fakedamage(id, "weapon_knife", fDamage, DMG_SLASH)
            damageIcon(id, eMasterSkull2[SKULL2_DAMAGE_TYPE])

            g_ePlayerData[id][PDATA_NEXT_DAMAGE] = fCurrentTime + random_float(eMasterSkull2[SKULL2_FREQ][0], eMasterSkull2[SKULL2_FREQ][1])
        }

        if ( g_ePlayerData[id][PDATA_STUN] )
        {
            masterFade(id, iDuration, FADE_MODULATE,
            random_num(eMasterStun[STUN_COLOR_MIN][0], eMasterStun[STUN_COLOR_MAX][0]),
            random_num(eMasterStun[STUN_COLOR_MIN][1], eMasterStun[STUN_COLOR_MAX][1]),
            random_num(eMasterStun[STUN_COLOR_MIN][2], eMasterStun[STUN_COLOR_MAX][2]),
            random_num(eMasterStun[STUN_COLOR_MIN][3], eMasterStun[STUN_COLOR_MAX][3]))
            masterShake(id, iAmplitude, iDuration, iFrequency)

            if ( !g_ePlayerData[id][PDATA_STUN_FOV] )
                g_ePlayerData[id][PDATA_STUN_FOV] = pev(id, pev_fov)

            if ( iFov != g_ePlayerData[id][PDATA_STUN_FOV_LAST] )
            {
                g_ePlayerData[id][PDATA_STUN_FOV_LAST] = iFov
                masterFov(id, iFov)
            }
        }
        else if ( g_ePlayerData[id][PDATA_STUN_FOV] )
        {
            masterFov(id, g_ePlayerData[id][PDATA_STUN_FOV])
            g_ePlayerData[id][PDATA_STUN_FOV] = 0
            g_ePlayerData[id][PDATA_STUN_FOV_LAST] = 0
        }

        if ( g_ePlayerData[id][PDATA_STUN2] )
        {
            user_slap(id, iDamage >= fHealth && !eMasterStun2[STUN2_KILL] ? 0 : iDamage, eMasterStun2[STUN2_DIRECTION])
            g_ePlayerData[id][PDATA_NEXT_STUN2] = fCurrentTime + random_float(eMasterStun2[STUN2_FREQ][0], eMasterStun2[STUN2_FREQ][1])
        }

        if ( g_ePlayerData[id][PDATA_UP] )
        {
            if ( !g_ePlayerData[id][PDATA_UP_JUMP_LAST] || iJump != g_ePlayerData[id][PDATA_UP_JUMP_LAST] )
            {
                g_ePlayerData[id][PDATA_UP_JUMP] = iJump
                g_ePlayerData[id][PDATA_UP_JUMP_LAST] = iJump
            }

            if ( !g_ePlayerData[id][PDATA_UP_GRAVITY] )
                pev(id, pev_gravity, g_ePlayerData[id][PDATA_UP_GRAVITY])

            if ( fGravity != g_ePlayerData[id][PDATA_UP_GRAVITY_LAST] )
            {
                g_ePlayerData[id][PDATA_UP_GRAVITY_LAST] = fGravity
                set_pev(id, pev_gravity, fGravity)
            }
        }
        else if ( g_ePlayerData[id][PDATA_UP_JUMP_LAST] )
        {
            set_pev(id, pev_gravity, g_ePlayerData[id][PDATA_UP_GRAVITY])
            g_ePlayerData[id][PDATA_UP_JUMP] = 0
            g_ePlayerData[id][PDATA_UP_JUMP_LAST] = 0
            g_ePlayerData[id][PDATA_UP_GRAVITY] = 0.0
            g_ePlayerData[id][PDATA_UP_GRAVITY_LAST] = 1.0
        }

        if ( g_ePlayerData[id][PDATA_WINGS] )
        {
            if ( eMasterWings[WINGS_NOCLIP] && !g_ePlayerData[id][PDATA_WINGS_NOCLIP] )
            {
                set_pev(id, pev_movetype, MOVETYPE_NOCLIP)
                g_ePlayerData[id][PDATA_WINGS_NOCLIP] = true
            }

            if ( !(eMasterWings[WINGS_NOCLIP]) && !g_ePlayerData[id][PDATA_WINGS_GODMODE] )
            {
                set_user_godmode(id, true)
                g_ePlayerData[id][PDATA_WINGS_GODMODE] = true
            }
        }
        else if ( g_ePlayerData[id][PDATA_WINGS_NOCLIP] || g_ePlayerData[id][PDATA_WINGS_GODMODE] )
        {
            if ( g_ePlayerData[id][PDATA_WINGS_NOCLIP] )
            {
                set_pev(id, pev_movetype, MOVETYPE_WALK)
                g_ePlayerData[id][PDATA_WINGS_NOCLIP] = false
            }

            if ( g_ePlayerData[id][PDATA_WINGS_GODMODE] )
            {
                set_user_godmode(id, false)
                g_ePlayerData[id][PDATA_WINGS_GODMODE] = false
            }
        }
    }

    for ( new i = 0; i < g_iMaster; i ++ )
    {
        ArrayGetArray(g_aMaster, i, eMaster)

        if ( eMaster[MASTER_FLAGS] & FLAG_SELECT )
            masterBeam(eMaster)

        if ( eMaster[MASTER_FLAGS] & FLAG_ACTIVE )
        {
            if ( eMaster[MASTER_NEXT_DISABLE] > 0.0
            && fCurrentTime >= eMaster[MASTER_NEXT_DISABLE] )
            {
                eMaster[MASTER_FLAGS] &= ~FLAG_ACTIVE
                eMaster[MASTER_NEXT_DISABLE] = 0.0
                eMaster[MASTER_NEXT_ENABLE] = fCurrentTime + random_float(eMaster[MASTER_ACTIVE_COOLDOWN][0], eMaster[MASTER_ACTIVE_COOLDOWN][1])
                ArraySetArray(g_aMaster, i, eMaster)

                masterSound(eMaster[MASTER_ID], SOUND_DISABLED, .bPlayer = false)
            }
        }
        else
        {
            if ( eMaster[MASTER_NEXT_ENABLE] > 0.0
            && fCurrentTime >= eMaster[MASTER_NEXT_ENABLE] )
            {
                eMaster[MASTER_FLAGS] |= FLAG_ACTIVE
                eMaster[MASTER_NEXT_ENABLE] = 0.0

                if ( eMaster[MASTER_FLAGS] & FLAG_ACTIVE_DURATION )
                    eMaster[MASTER_NEXT_DISABLE] = fCurrentTime + random_float(eMaster[MASTER_ACTIVE_DURATION][0], eMaster[MASTER_ACTIVE_DURATION][1])

                ArraySetArray(g_aMaster, i, eMaster)

                masterSound(eMaster[MASTER_ID], SOUND_ENABLED, .bPlayer = false, .iPitch = 150)
            }
        }
    }
}

public masterCreate(id, iItem)
{
    new iEnt
    iEnt = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))

    if ( !pev_valid(iEnt) )
        return;

    new eMaster[MASTER]
    ArrayGetArray(g_aMasterConfig, iItem, eMaster)

    eMaster[MASTER_ID] = iEnt
    eMaster[MASTER_ITEM] = iItem
    eMaster[MASTER_DATA] = ArrayClone(eMaster[MASTER_DATA])
    eMaster[MASTER_SCALE][0] = eMaster[MASTER_SCALE][1] = eMaster[MASTER_SCALE][2] = g_eSettings[SETTING_SIZE_BASE]
    if ( id )
    {
        g_ePlayerData[id][PDATA_MASTER_GHOST] = iEnt
        g_ePlayerData[id][PDATA_MASTER_ACTION] = true
        g_ePlayerData[id][PDATA_SCALE_UP] = true
        g_ePlayerData[id][PDATA_SCALE_FACTOR] = 0
        g_ePlayerData[id][PDATA_OFFSET] = g_eSettings[SETTING_OFFSET_BASE]
    }

    set_pev(iEnt, MASTER_ARRAY_ITEM, g_iMaster)
    set_pev(iEnt, pev_impulse, MASTER_KEY)
    set_pev(iEnt, pev_classname, g_szCN)

    set_pev(iEnt, pev_scale, eMaster[MASTER_ICON_SCALE])
    set_pev(iEnt, pev_rendermode, kRenderTransTexture)

    ArrayPushArray(g_aMaster, eMaster)
    g_iMaster ++

    dllfunc(DLLFunc_Spawn, iEnt)
}

stock masterRemove(iItem)
{
    new eMaster[MASTER]
    ArrayDeleteItem(g_aMaster, iItem)
    g_iMaster --

    for ( new i = iItem; i < g_iMaster; i ++ )
    {
        ArrayGetArray(g_aMaster, i, eMaster)
        set_pev(eMaster[MASTER_ID], MASTER_ARRAY_ITEM, i)
    }
}

public saveData(id)
{
    new eMaster[MASTER],
        szFile[128], iFile,
        szData[64]

    get_mapname(szFile, charsmax(szFile))
    format(szFile, charsmax(szFile), "maps/%s_ZoneMaster.ini", szFile)

    iFile = fopen(szFile, "wt")
    if ( !iFile )
        return PLUGIN_HANDLED

    for ( new i = 0; i < g_iMaster; i ++ )
    {
        ArrayGetArray(g_aMaster, i, eMaster)

        formatex(szData, charsmax(szData), "[%d]^n", i)
        fputs(iFile, szData)

        formatex(szData, charsmax(szData), "item = %d^n", eMaster[MASTER_ITEM])
        fputs(iFile, szData)

        eMaster[MASTER_FLAGS] &= ~FLAG_SELECT
        formatex(szData, charsmax(szData), "flags = %d^n", eMaster[MASTER_FLAGS])
        fputs(iFile, szData)

        formatex(szData, charsmax(szData), "status = %d^n", eMaster[MASTER_STATUS])
        fputs(iFile, szData)

        formatex(szData, charsmax(szData), "scale = %.2f %.2f %.2f^n",
        eMaster[MASTER_SCALE][0], eMaster[MASTER_SCALE][1], eMaster[MASTER_SCALE][2])
        fputs(iFile, szData)

        formatex(szData, charsmax(szData), "origin = %.2f %.2f %.2f^n",
        eMaster[MASTER_ORIGIN][0], eMaster[MASTER_ORIGIN][1], eMaster[MASTER_ORIGIN][2])
        fputs(iFile, szData)

        for ( new j = 0; j < 8; j ++ )
        {
            formatex(szData, charsmax(szData), "corner_%d = %.2f %.2f %.2f^n",
            j + 1, eMaster[MASTER_CORNERS][j * 3], eMaster[MASTER_CORNERS][(j * 3) + 1], eMaster[MASTER_CORNERS][(j * 3) + 2])
            fputs(iFile, szData)
        }
    }

    client_print_color(id, id, "%L %L", id, "MASTER_CHAT_TAG", id, "MASTER_CHAT_SAVE", szFile)
    fclose(iFile)

    masterSound(id, SOUND_MENU_NAV)
    masterMenu(id, MENU_ROOT)
    return PLUGIN_HANDLED
}

public loadData()
{
    new szFile[128], iFile,
        szData[64], szKey[32], szValue[32],
        iItem, iFlags, iStatus, Float:fScale[3], Float:fOrigin[3], Float:fCorners[24],
        iCorner, iCount = -1

    get_mapname(szFile, charsmax(szFile))
    format(szFile, charsmax(szFile), "maps/%s_ZoneMaster.ini", szFile)

    iFile = fopen(szFile, "rt")
    if ( !iFile )
        return PLUGIN_HANDLED

    while( !feof(iFile) )
    {
        fgets(iFile, szData, charsmax(szData))

        if ( szData[0] == '[' )
        {
            if ( iCount != -1 )
                loadDataMaster(fCorners, fScale, fOrigin, iItem, iFlags, iStatus, iCount)

            iCount ++
        }
        else
        {
            strtok(szData, szKey, charsmax( szKey ), szValue, charsmax( szValue ), '=')
            trim(szKey)
            trim(szValue)

            if ( equal(szKey, "item") )
            {
                iItem = str_to_num(szValue)
            }
            else if ( equal(szKey, "flags") )
            {
                iFlags = str_to_num(szValue)
            }
            else if ( equal(szKey, "status") )
            {
                iStatus = str_to_num(szValue)
            }
            else if ( equal(szKey, "scale") )
            {
                strtok(szValue, szKey, charsmax(szKey), szValue, charsmax(szValue), ' ')
                fScale[0] = str_to_float(szKey)

                strtok(szValue, szKey, charsmax(szKey), szValue, charsmax(szValue), ' ')
                fScale[1] = str_to_float(szKey)
                fScale[2] = str_to_float(szValue)
            }
            else if ( equal(szKey, "origin") )
            {
                strtok(szValue, szKey, charsmax(szKey), szValue, charsmax(szValue), ' ')
                fOrigin[0] = str_to_float(szKey)

                strtok(szValue, szKey, charsmax(szKey), szValue, charsmax(szValue), ' ')
                fOrigin[1] = str_to_float(szKey)
                fOrigin[2] = str_to_float(szValue)
            }
            else if ( contain(szKey, "corner") != -1 )
            {
                iCorner = str_to_num(szKey[7])

                strtok(szValue, szKey, charsmax(szKey), szValue, charsmax(szValue), ' ')
                fCorners[(iCorner - 1) * 3] = str_to_float(szKey)

                strtok(szValue, szKey, charsmax(szKey), szValue, charsmax(szValue), ' ')
                fCorners[(iCorner - 1) * 3 + 1] = str_to_float(szKey)
                fCorners[(iCorner - 1) * 3 + 2] = str_to_float(szValue)
            }
        }
    }

    if ( iCount != -1 )
        loadDataMaster(fCorners, fScale, fOrigin, iItem, iFlags, iStatus, iCount)

    fclose(iFile)
    return PLUGIN_HANDLED
}

stock loadDataMaster(Float:fCorners[24], Float:fScale[3], Float:fOrigin[3], iItem, iFlags, iStatus, iCount)
{
    new eMaster[MASTER]
    masterCreate(0, iItem)
    ArrayGetArray(g_aMaster, iCount, eMaster)

    eMaster[MASTER_FLAGS] = iFlags
    eMaster[MASTER_STATUS] = iStatus
    xs_vec_copy(fScale, eMaster[MASTER_SCALE])
    xs_vec_copy(fOrigin, eMaster[MASTER_ORIGIN])
    for ( new i = 0; i < 24; i ++ )
        eMaster[MASTER_CORNERS][i] = fCorners[i]

    set_pev(eMaster[MASTER_ID], pev_origin, fOrigin)
    masterSetBox(eMaster)
    masterSetAnim(eMaster)
    masterSetActive(eMaster)
    ArraySetArray(g_aMaster, iCount, eMaster)
}

public masterNoClip(id)
{
    set_user_noclip(id, !get_user_noclip(id))

    masterSound(id, SOUND_MENU_NAV)
    masterMenu(id, MENU_ROOT)
}

public masterGodMod(id)
{
    set_user_godmode(id, !get_user_godmode(id))

    masterSound(id, SOUND_MENU_NAV)
    masterMenu(id, MENU_ROOT)
}

public fwdUpdateClientData(id, iSendWeapons, iHandle)
{
    if ( g_ePlayerData[id][PDATA_MASTER_GHOST] )
    {
        set_cd(iHandle, CD_WeaponAnim, 0)
        set_cd(iHandle, CD_flNextAttack, get_gametime() + 0.1)
    }

    return FMRES_IGNORED
}

public fwdAddToFullPack(es, e, iEnt, iHost, iHostFlags, iPlayer, pSet)
{
    if ( !pev_valid(iEnt)
    || !isMaster(iEnt)
    || !get_orig_retval() )
        return FMRES_IGNORED

    new eMaster[MASTER], bool:bHidden
    if ( masterGet(eMaster, iEnt) != -1
    && eMaster[MASTER_FLAGS] & FLAG_ICON )
    {
        bHidden = !(eMaster[MASTER_FLAGS] & FLAG_ACTIVE) || !(CsTeams:eMaster[MASTER_TEAM] & cs_get_user_team(iHost))
        set_es(es, ES_RenderAmt, bHidden ? g_eSettings[SETTING_ALPHA_INACTIVE] : eMaster[MASTER_ICON_ALPHA])
    }

    return FMRES_IGNORED
}

public fwdSpawn(iEnt)
{
    if ( !isMaster(iEnt) )
        return HAM_IGNORED

    set_pev(iEnt, pev_solid, SOLID_NOT)
    set_pev(iEnt, pev_movetype, MOVETYPE_NONE)

    return HAM_IGNORED
}

public fwdKilled(id, iAttacker, bGib)
{
    g_ePlayerData[id][PDATA_MASTER_ACTION] = false

    if ( g_ePlayerData[id][PDATA_MASTER_GHOST] )
    {
        new eMaster[MASTER], iItem

        if ( (iItem = masterGet(eMaster, g_ePlayerData[id][PDATA_MASTER_GHOST])) != -1 )
        {
            masterKill(eMaster[MASTER_ID])
            masterRemove(iItem)
            g_ePlayerData[id][PDATA_MASTER_GHOST] = 0
        }
    }

    masterResetPlayer(id)

    return HAM_IGNORED
}

public fwdResetMaxSpeedPlayer(id)
{
    if ( !is_user_alive(id)
    || !g_ePlayerData[id][PDATA_LIGHTNING] )
        return FMRES_IGNORED

    set_pev(id, pev_maxspeed, pev(id, pev_maxspeed) * g_ePlayerData[id][PDATA_LIGHTNING_SPEED])
    return FMRES_IGNORED
}

public fwdWeaponReload(iEnt)
{
    if ( !pev_valid(iEnt)
    || (!get_pdata_int(iEnt, MEMBER_IN_RELOAD) && !get_pdata_int(iEnt, MEMBER_IN_SPECIAL_RELOAD)) )
        return HAM_IGNORED

    new id
    id = get_pdata_cbase(iEnt, MEMBER_OWNER)
    if ( !is_user_alive(id)
    || !g_ePlayerData[id][PDATA_CLOCK] )
        return HAM_IGNORED

    new Float:fSpeed
    fSpeed = get_pdata_float(iEnt, MEMBER_NEXT_IDLE) * g_ePlayerData[id][PDATA_CLOCK_RELOAD_SPEED]
    set_pdata_float(id, MEMBER_NEXT_ATTACK, fSpeed)
    set_pdata_float(iEnt, MEMBER_NEXT_PRIMARY, fSpeed)
    set_pdata_float(iEnt, MEMBER_NEXT_SECONDARY, fSpeed)
    set_pdata_float(iEnt, MEMBER_NEXT_IDLE, fSpeed)

    if ( cs_get_weapon_id(iEnt) == CSW_DEAGLE )
        set_task(fSpeed, "weaponPlayIdle", id + TASK_WEAPON_IDLE)

    return HAM_IGNORED
}

public fwdWeaponAttack(iEnt)
{
    if ( !pev_valid(iEnt) )
        return HAM_IGNORED

    new id
    id = get_pdata_cbase(iEnt, MEMBER_OWNER)
    if ( !is_user_alive(id)
    || !g_ePlayerData[id][PDATA_CLOCK] )
        return HAM_IGNORED

    new Float:fPunchAngle[3]
    pev(id, pev_punchangle, fPunchAngle)
    fPunchAngle[0] *= g_ePlayerData[id][PDATA_CLOCK_RECOIL_SETTING]
    fPunchAngle[1] *= g_ePlayerData[id][PDATA_CLOCK_RECOIL_SETTING]
    set_pev(id, pev_punchangle, fPunchAngle)

    set_pdata_float(iEnt, MEMBER_NEXT_PRIMARY, get_pdata_float(iEnt, MEMBER_NEXT_PRIMARY) * g_ePlayerData[id][PDATA_CLOCK_ATTACK_SPEED])
    set_pdata_float(iEnt, MEMBER_NEXT_SECONDARY, get_pdata_float(iEnt, MEMBER_NEXT_SECONDARY) * g_ePlayerData[id][PDATA_CLOCK_ATTACK_SPEED])

    return HAM_IGNORED
}

public fwdWeaponDeploy(iEnt)
{
    if ( !pev_valid(iEnt) )
        return HAM_IGNORED

    new id
    id = get_pdata_cbase(iEnt, MEMBER_OWNER)
    if ( !is_user_alive(id)
    || !g_ePlayerData[id][PDATA_CLOCK] )
        return HAM_IGNORED

    new Float:fSpeed
    fSpeed = get_pdata_float(id, MEMBER_NEXT_ATTACK) * g_ePlayerData[id][PDATA_CLOCK_DEPLOY_SPEED]
    set_pdata_float(id, MEMBER_NEXT_ATTACK, fSpeed)
    set_pdata_float(iEnt, MEMBER_NEXT_PRIMARY, fSpeed)
    set_pdata_float(iEnt, MEMBER_NEXT_SECONDARY, fSpeed)
    set_pdata_float(iEnt, MEMBER_NEXT_IDLE, fSpeed)

    if ( cs_get_weapon_id(iEnt) == CSW_DEAGLE )
        set_task(fSpeed, "weaponPlayIdle", id + TASK_WEAPON_IDLE)

    return HAM_IGNORED
}

public fwdPreThink(id)
{
    if ( !is_user_alive(id) )
        return HAM_IGNORED

    new iButton, iOldButton
    iButton = pev(id, pev_button)
    iOldButton = pev(id, pev_oldbuttons)

    if ( g_ePlayerData[id][PDATA_MASTER_GHOST] )
    {
        if ( get_gametime() >= g_ePlayerData[id][PDATA_NEXT_OFFSET] )
        {
            if ( iButton & IN_ATTACK )
            {
                g_ePlayerData[id][PDATA_OFFSET]      += g_eSettings[SETTING_OFFSET_STEP]
                g_ePlayerData[id][PDATA_OFFSET]      = floatclamp(g_ePlayerData[id][PDATA_OFFSET], g_eSettings[SETTING_OFFSET][0], g_eSettings[SETTING_OFFSET][1])
                g_ePlayerData[id][PDATA_NEXT_OFFSET] = get_gametime() + 0.1
            }
            else if ( iButton & IN_ATTACK2 )
            {
                g_ePlayerData[id][PDATA_OFFSET]      -= g_eSettings[SETTING_OFFSET_STEP]
                g_ePlayerData[id][PDATA_OFFSET]      = floatclamp(g_ePlayerData[id][PDATA_OFFSET], g_eSettings[SETTING_OFFSET][0], g_eSettings[SETTING_OFFSET][1])
                g_ePlayerData[id][PDATA_NEXT_OFFSET] = get_gametime() + 0.1
            }
        }

        iButton &= ~(IN_ATTACK | IN_ATTACK2)
        set_pev(id, pev_button, iButton)
    }

    if ( g_ePlayerData[id][PDATA_UP] )
    {
        if ( pev(id, pev_flags) & FL_ONGROUND )
        {
            g_ePlayerData[id][PDATA_UP_JUMP] = g_ePlayerData[id][PDATA_UP_JUMP_LAST]
        }
        else
        {
            if ( g_ePlayerData[id][PDATA_UP_JUMP] > 0
            && (iButton & IN_JUMP && !(iOldButton & IN_JUMP)) )
            {
                new Float:fVelocity[3]
                pev(id, pev_velocity, fVelocity)
                fVelocity[2] = 255.0
                set_pev(id, pev_velocity, fVelocity)

                g_ePlayerData[id][PDATA_UP_JUMP] --
            }
        }
    }

    return HAM_IGNORED
}

public fwdTakeDamage(id, iInflictor, iAttacker, Float:fDamage, iDamageBits)
{
    if ( !is_user_alive(id)
    || !is_user_alive(iAttacker)
    || (!g_ePlayerData[id][PDATA_SHIELD] && !g_ePlayerData[iAttacker][PDATA_SKULL]) )
        return HAM_IGNORED

    new iWeaponActive
    iWeaponActive = cs_get_user_weapon_entity(iAttacker)

    fDamage += (g_ePlayerData[iAttacker][PDATA_SKULL_DAMAGE] * fDamage)
    fDamage -= (g_ePlayerData[id][PDATA_SHIELD_ABSORB] * fDamage)
    SetHamParamFloat(4, fDamage)

    if ( g_ePlayerData[iAttacker][PDATA_SKULL] )
    {
        new Float:fHealth
        pev(iAttacker, pev_health, fHealth)
        set_pev(iAttacker, pev_health, fHealth + (g_ePlayerData[iAttacker][PDATA_SKULL_BLOOD] * fDamage))
    }

    if ( g_ePlayerData[id][PDATA_SHIELD]
    && !g_ePlayerData[id][PDATA_SHIELD_REFLECTED] )
    {
        g_ePlayerData[iAttacker][PDATA_SHIELD_REFLECTED] = true
        ExecuteHam(Ham_TakeDamage, iAttacker, iWeaponActive, id, (g_ePlayerData[id][PDATA_SHIELD_REFLECT] * fDamage), DMG_GENERIC)
        g_ePlayerData[iAttacker][PDATA_SHIELD_REFLECTED] = false
    }

    return HAM_IGNORED
}

public masterTrace(eMaster[MASTER], id)
{
    new Float:fVec1[3]

    pev(id, pev_origin, eMaster[MASTER_ORIGIN])
    pev(id, pev_view_ofs, fVec1)
    xs_vec_add(eMaster[MASTER_ORIGIN], fVec1, eMaster[MASTER_ORIGIN])

    pev(id, pev_v_angle, fVec1)
    engfunc(EngFunc_MakeVectors, fVec1)
    global_get(glb_v_forward, fVec1)

    xs_vec_mul_scalar(fVec1, g_ePlayerData[id][PDATA_OFFSET], fVec1)
    xs_vec_add(fVec1, eMaster[MASTER_ORIGIN], fVec1)

    engfunc(EngFunc_TraceLine, eMaster[MASTER_ORIGIN], fVec1, IGNORE_MONSTERS, id, 0)
    get_tr2(0, TR_vecEndPos, eMaster[MASTER_ORIGIN])

    masterSetBox(eMaster, true)
    masterSetOffset(eMaster)
    masterSetBox(eMaster, true)
    masterBeam(eMaster)

    set_pev(eMaster[MASTER_ID], pev_origin, eMaster[MASTER_ORIGIN])
}

stock masterCheck(id)
{
    new eMaster[MASTER], Float:fVec1[3], Float:fVec2[3], Float:fVec3[3], Float:fMins[3], Float:fMaxs[3], Float:fNearest[3]
    new iBest, Float:fBestDist, Float:fDot, Float:fDist

    pev(id, pev_origin, fVec1)
    pev(id, pev_view_ofs, fVec2)
    xs_vec_add(fVec1, fVec2, fVec1)

    pev(id, pev_v_angle, fVec2)
    engfunc(EngFunc_MakeVectors, fVec2)
    global_get(glb_v_forward, fVec2)

    iBest = -1
    fBestDist = g_eSettings[SETTING_MASTER_CHECK]
    for ( new i = 0; i < g_iMaster; i ++ )
    {
        ArrayGetArray(g_aMaster, i, eMaster)
        xs_vec_sub(eMaster[MASTER_ORIGIN], fVec1, fVec3)
        fDot = xs_vec_dot(fVec2, fVec3)

        if ( fDot < 0.0 )
            continue

        pev(eMaster[MASTER_ID], pev_absmin, fMins)
        pev(eMaster[MASTER_ID], pev_absmax, fMaxs)
        xs_vec_mul_scalar(fVec2, fDot, fVec3)
        xs_vec_add(fVec3, fVec1, fVec3)

        fNearest[0] = floatclamp(fVec3[0], fMins[0], fMaxs[0])
        fNearest[1] = floatclamp(fVec3[1], fMins[1], fMaxs[1])
        fNearest[2] = floatclamp(fVec3[2], fMins[2], fMaxs[2])
        fDist = get_distance_f(fVec3, fNearest)
        if ( fDist < fBestDist )
        {
            fBestDist = fDist
            iBest = i
        }
    }

    if ( iBest != -1
    && g_ePlayerData[id][PDATA_MASTER_MENU] != iBest )
    {
        ArrayGetArray(g_aMaster, g_ePlayerData[id][PDATA_MASTER_MENU], eMaster)
        eMaster[MASTER_FLAGS] &= ~FLAG_SELECT
        ArraySetArray(g_aMaster, g_ePlayerData[id][PDATA_MASTER_MENU], eMaster)

        ArrayGetArray(g_aMaster, iBest, eMaster)
        eMaster[MASTER_FLAGS] |= FLAG_SELECT
        ArraySetArray(g_aMaster, iBest, eMaster)
        g_ePlayerData[id][PDATA_MASTER_MENU] = iBest
    }
}

stock masterSetBox(eMaster[MASTER], bool:bSetCorners = false)
{
    if ( bSetCorners )
        boxCorners(eMaster)

    for ( new i = 0; i < 3; i ++ )
    {
        eMaster[MASTER_MINS][i] = eMaster[MASTER_CORNERS][i]
        eMaster[MASTER_MAXS][i] = eMaster[MASTER_CORNERS][i]
    }

    for ( new i = 1; i < 8; i ++ )
    {
        for ( new j = 0; j < 3; j ++ )
        {
            eMaster[MASTER_MINS][j] = floatmin(eMaster[MASTER_MINS][j], eMaster[MASTER_CORNERS][i * 3 + j])
            eMaster[MASTER_MAXS][j] = floatmax(eMaster[MASTER_MAXS][j], eMaster[MASTER_CORNERS][i * 3 + j])
        }
    }
}

public boxCorners(eMaster[MASTER])
{
    eMaster[MASTER_CORNERS][0]  = eMaster[MASTER_ORIGIN][0] - eMaster[MASTER_SCALE][0]
    eMaster[MASTER_CORNERS][1]  = eMaster[MASTER_ORIGIN][1] - eMaster[MASTER_SCALE][1]
    eMaster[MASTER_CORNERS][2]  = eMaster[MASTER_ORIGIN][2] - eMaster[MASTER_SCALE][2]

    eMaster[MASTER_CORNERS][3]  = eMaster[MASTER_ORIGIN][0] + eMaster[MASTER_SCALE][0]
    eMaster[MASTER_CORNERS][4]  = eMaster[MASTER_ORIGIN][1] - eMaster[MASTER_SCALE][1]
    eMaster[MASTER_CORNERS][5]  = eMaster[MASTER_ORIGIN][2] - eMaster[MASTER_SCALE][2]

    eMaster[MASTER_CORNERS][6]  = eMaster[MASTER_ORIGIN][0] - eMaster[MASTER_SCALE][0]
    eMaster[MASTER_CORNERS][7]  = eMaster[MASTER_ORIGIN][1] + eMaster[MASTER_SCALE][1]
    eMaster[MASTER_CORNERS][8]  = eMaster[MASTER_ORIGIN][2] - eMaster[MASTER_SCALE][2]

    eMaster[MASTER_CORNERS][9]  = eMaster[MASTER_ORIGIN][0] + eMaster[MASTER_SCALE][0]
    eMaster[MASTER_CORNERS][10] = eMaster[MASTER_ORIGIN][1] + eMaster[MASTER_SCALE][1]
    eMaster[MASTER_CORNERS][11] = eMaster[MASTER_ORIGIN][2] - eMaster[MASTER_SCALE][2]

    eMaster[MASTER_CORNERS][12] = eMaster[MASTER_ORIGIN][0] - eMaster[MASTER_SCALE][0]
    eMaster[MASTER_CORNERS][13] = eMaster[MASTER_ORIGIN][1] - eMaster[MASTER_SCALE][1]
    eMaster[MASTER_CORNERS][14] = eMaster[MASTER_ORIGIN][2] + eMaster[MASTER_SCALE][2]

    eMaster[MASTER_CORNERS][15] = eMaster[MASTER_ORIGIN][0] + eMaster[MASTER_SCALE][0]
    eMaster[MASTER_CORNERS][16] = eMaster[MASTER_ORIGIN][1] - eMaster[MASTER_SCALE][1]
    eMaster[MASTER_CORNERS][17] = eMaster[MASTER_ORIGIN][2] + eMaster[MASTER_SCALE][2]

    eMaster[MASTER_CORNERS][18] = eMaster[MASTER_ORIGIN][0] - eMaster[MASTER_SCALE][0]
    eMaster[MASTER_CORNERS][19] = eMaster[MASTER_ORIGIN][1] + eMaster[MASTER_SCALE][1]
    eMaster[MASTER_CORNERS][20] = eMaster[MASTER_ORIGIN][2] + eMaster[MASTER_SCALE][2]

    eMaster[MASTER_CORNERS][21] = eMaster[MASTER_ORIGIN][0] + eMaster[MASTER_SCALE][0]
    eMaster[MASTER_CORNERS][22] = eMaster[MASTER_ORIGIN][1] + eMaster[MASTER_SCALE][1]
    eMaster[MASTER_CORNERS][23] = eMaster[MASTER_ORIGIN][2] + eMaster[MASTER_SCALE][2]
}

stock masterSetOffset(eMaster[MASTER])
{
    new Float:fVec1[3],
        Float:fGap, Float:fDist

    xs_vec_sub(eMaster[MASTER_ORIGIN], Float:{0.0, 0.0, 9999.9}, fVec1)
    engfunc(EngFunc_TraceLine, eMaster[MASTER_ORIGIN], fVec1, IGNORE_MONSTERS, eMaster[MASTER_ID], 0)
    get_tr2(0, TR_vecEndPos, fVec1)
    fDist = xs_vec_distance(eMaster[MASTER_ORIGIN], fVec1)
    fGap = eMaster[MASTER_ORIGIN][2] - eMaster[MASTER_MINS][2]

    if ( fDist < (fGap + 1.0) )
    {
        get_tr2(0, TR_vecPlaneNormal, fVec1)
        xs_vec_mul_scalar(fVec1, (fGap + 1.0) - fDist, fVec1)
        xs_vec_add(eMaster[MASTER_ORIGIN], fVec1, eMaster[MASTER_ORIGIN])
    }
}

stock masterSetAnim(eMaster[MASTER])
{
    set_pev(eMaster[MASTER_ID], pev_sequence, eMaster[MASTER_ANIM])
    set_pev(eMaster[MASTER_ID], pev_frame, 0.0)
    set_pev(eMaster[MASTER_ID], pev_framerate, 1.0)
    set_pev(eMaster[MASTER_ID], pev_animtime, get_gametime())
}

stock masterSetActive(eMaster[MASTER])
{
    new Float:fMins[3], Float:fMaxs[3]

    set_pev(eMaster[MASTER_ID], pev_solid, SOLID_TRIGGER)
    set_pev(eMaster[MASTER_ID], pev_movetype, MOVETYPE_NONE)
    xs_vec_sub(eMaster[MASTER_MINS], eMaster[MASTER_ORIGIN], fMins)
    xs_vec_sub(eMaster[MASTER_MAXS], eMaster[MASTER_ORIGIN], fMaxs)

    if ( eMaster[MASTER_FLAGS] & FLAG_ICON )
        engfunc(EngFunc_SetModel, eMaster[MASTER_ID], eMaster[MASTER_ICON])
    engfunc(EngFunc_SetSize, eMaster[MASTER_ID], fMins, fMaxs)
}

stock masterBeam(eMaster[MASTER])
{
    new Float:fCorners[8][3]
    xs_vec_copy(eMaster[MASTER_CORNERS][0],  fCorners[0])
    xs_vec_copy(eMaster[MASTER_CORNERS][3],  fCorners[1])
    xs_vec_copy(eMaster[MASTER_CORNERS][6],  fCorners[2])
    xs_vec_copy(eMaster[MASTER_CORNERS][9],  fCorners[3])
    xs_vec_copy(eMaster[MASTER_CORNERS][12], fCorners[4])
    xs_vec_copy(eMaster[MASTER_CORNERS][15], fCorners[5])
    xs_vec_copy(eMaster[MASTER_CORNERS][18], fCorners[6])
    xs_vec_copy(eMaster[MASTER_CORNERS][21], fCorners[7])

    beamDraw(fCorners[0], fCorners[1], eMaster[MASTER_FLAGS] & FLAG_ACTIVE != 0)
    beamDraw(fCorners[1], fCorners[3], eMaster[MASTER_FLAGS] & FLAG_ACTIVE != 0)
    beamDraw(fCorners[3], fCorners[2], eMaster[MASTER_FLAGS] & FLAG_ACTIVE != 0)
    beamDraw(fCorners[2], fCorners[0], eMaster[MASTER_FLAGS] & FLAG_ACTIVE != 0)

    beamDraw(fCorners[0], fCorners[4], eMaster[MASTER_FLAGS] & FLAG_ACTIVE != 0)
    beamDraw(fCorners[1], fCorners[5], eMaster[MASTER_FLAGS] & FLAG_ACTIVE != 0)
    beamDraw(fCorners[2], fCorners[6], eMaster[MASTER_FLAGS] & FLAG_ACTIVE != 0)
    beamDraw(fCorners[3], fCorners[7], eMaster[MASTER_FLAGS] & FLAG_ACTIVE != 0)

    beamDraw(fCorners[4], fCorners[5], eMaster[MASTER_FLAGS] & FLAG_ACTIVE != 0)
    beamDraw(fCorners[5], fCorners[7], eMaster[MASTER_FLAGS] & FLAG_ACTIVE != 0)
    beamDraw(fCorners[7], fCorners[6], eMaster[MASTER_FLAGS] & FLAG_ACTIVE != 0)
    beamDraw(fCorners[6], fCorners[4], eMaster[MASTER_FLAGS] & FLAG_ACTIVE != 0)
}

stock beamDraw(Float:fStart[3], Float:fEnd[3], bool:bActive)
{
    message_begin_f(MSG_PVS, SVC_TEMPENTITY, fStart)
    write_byte(TE_BEAMPOINTS)
    write_coord_f(fStart[0])
    write_coord_f(fStart[1])
    write_coord_f(fStart[2])
    write_coord_f(fEnd[0])
    write_coord_f(fEnd[1])
    write_coord_f(fEnd[2])
    write_short(g_eSettings[SETTING_BEAM])
    write_byte(0)
    write_byte(0)
    write_byte(1)
    write_byte(g_eSettings[SETTING_BEAM_WIDTH])
    write_byte(0)
    if ( bActive )
    {
        write_byte(g_eSettings[SETTING_COLOR_ACTIVE][0])
        write_byte(g_eSettings[SETTING_COLOR_ACTIVE][1])
        write_byte(g_eSettings[SETTING_COLOR_ACTIVE][2])
    }
    else
    {
        write_byte(g_eSettings[SETTING_COLOR_INACTIVE][0])
        write_byte(g_eSettings[SETTING_COLOR_INACTIVE][1])
        write_byte(g_eSettings[SETTING_COLOR_INACTIVE][2])
    }
    write_byte(g_eSettings[SETTING_BEAM_ALPHA])
    write_byte(0)
    message_end()
}

stock ammoPickup(id, iWeaponActive, iAmount)
{
    new iAmmoType
    iAmmoType = get_pdata_int(iWeaponActive, MEMBER_AMMO_TYPE)

    message_begin(MSG_ONE_UNRELIABLE, g_iAmmoPickup, .player = id)
    write_byte(iAmmoType)
    write_byte(iAmount)
    message_end()
}

stock bombPickup(id, iGrenade)
{
    message_begin(MSG_ONE_UNRELIABLE, g_iWeapPickup, .player = id)
    write_byte(iGrenade)
    message_end()
}

public weaponPlayIdle(iTask)
{
    new id = iTask - TASK_WEAPON_IDLE
    message_begin(MSG_ONE, SVC_WEAPONANIM, .player = id)
    write_byte(0)
    write_byte(pev(id, pev_body))
    message_end()
}

stock damageIcon(id, iType)
{
    message_begin(MSG_ONE, g_iDamage, .player = id)
    write_byte(0)
    write_byte(0)
    write_long(iType)
    write_coord(0)
    write_coord(0)
    write_coord(0)
    message_end()
}

stock masterFade(id, iDuration, iFlags, iRed, iGreen, iBlue, iAlpha)
{
    message_begin(MSG_ONE_UNRELIABLE, g_iScreenFade, .player = id)
    write_short(iDuration * 4096)
    write_short(0)
    write_short(iFlags)
    write_byte(iRed)
    write_byte(iGreen)
    write_byte(iBlue)
    write_byte(iAlpha)
    message_end()
}

stock masterShake(id, iAmplitude, iDuration, iFrequency)
{
    message_begin(MSG_ONE_UNRELIABLE, g_iScreenShake, .player = id)
    write_short(iAmplitude * 4096)
    write_short(iDuration * 4096)
    write_short(iFrequency * 4096)
    message_end()
}

stock masterFov(id, iDegree)
{
    message_begin(MSG_ONE_UNRELIABLE, g_iSetFov, .player = id)
    write_byte(iDegree)
    message_end()
}

stock masterReset(eMaster[MASTER])
{
    eMaster[MASTER_FLAGS] &= ~FLAG_ACTIVE
    eMaster[MASTER_NEXT_ENABLE] = 0.0

    if ( eMaster[MASTER_FLAGS] & FLAG_ACTIVE_DURATION )
        eMaster[MASTER_NEXT_DISABLE] = get_gametime() + random_float(eMaster[MASTER_ACTIVE_DURATION][0], eMaster[MASTER_ACTIVE_DURATION][1])
    else
        eMaster[MASTER_NEXT_DISABLE] = 0.0
}

stock masterResetPlayer(id)
{
    g_ePlayerData[id][PDATA_NEXT_AMMO] = 0.0
    g_ePlayerData[id][PDATA_NEXT_BOMB] = 0.0
    g_ePlayerData[id][PDATA_NEXT_HEALTH] = 0.0
    g_ePlayerData[id][PDATA_NEXT_SHIELD] = 0.0
    g_ePlayerData[id][PDATA_NEXT_DAMAGE] = 0.0
    g_ePlayerData[id][PDATA_NEXT_STUN] = 0.0
}

stock masterSound(iEnt, iSound, iChan = CHAN_ITEM, bool:bPlayer = true, iFlags = 0, iPitch = PITCH_NORM)
{
    new szSample[64]

    switch( iSound )
    {
        case SOUND_MENU_NAV:    copy(szSample, charsmax(szSample), g_eSettings[SETTING_SOUND_MENU_NAV])
        case SOUND_MENU_REMOVE: copy(szSample, charsmax(szSample), g_eSettings[SETTING_SOUND_MENU_REMOVE])
        case SOUND_MENU_ALERT:  copy(szSample, charsmax(szSample), g_eSettings[SETTING_SOUND_MENU_ALERT])
        case SOUND_ENABLED:     copy(szSample, charsmax(szSample), g_eSettings[SETTING_SOUND_SUITCHARGE])
        case SOUND_DISABLED:    copy(szSample, charsmax(szSample), g_eSettings[SETTING_SOUND_BLIP2])
        case SOUND_CLIP1:       copy(szSample, charsmax(szSample), g_eSettings[SETTING_SOUND_CLIP1])
    }

    if ( bPlayer )
        client_cmd(iEnt, "spk %s", szSample)
    else
        engfunc(EngFunc_EmitSound, iEnt, iChan, szSample, VOL_NORM, ATTN_NORM, iFlags, iPitch)
}

stock bool:isMasterActive(eMaster[MASTER], Float:fOrigin[3], id)
{
    if ( eMaster[MASTER_FLAGS] & FLAG_ACTIVE
    && CsTeams:eMaster[MASTER_TEAM] & cs_get_user_team(id)
    && fOrigin[0] >= eMaster[MASTER_MINS][0] && fOrigin[0] <= eMaster[MASTER_MAXS][0]
    && fOrigin[1] >= eMaster[MASTER_MINS][1] && fOrigin[1] <= eMaster[MASTER_MAXS][1]
    && fOrigin[2] >= eMaster[MASTER_MINS][2] && fOrigin[2] <= eMaster[MASTER_MAXS][2] )
        return true

    return false
}

stock masterGet(eMaster[MASTER], iEnt)
{
    new iItem
    iItem = pev(iEnt, MASTER_ARRAY_ITEM)
    if ( iItem < 0 || iItem >= g_iMaster )
        return -1

    ArrayGetArray(g_aMaster, iItem, eMaster)
    return iItem
}

stock bool:isMaster(iEnt)
{
    return pev(iEnt, pev_impulse) == MASTER_KEY
}

stock masterKill(iEnt)
{
    if (pev_valid(iEnt))
        set_pev(iEnt, pev_flags, pev(iEnt, pev_flags) | FL_KILLME)
}

stock parseSetting(iType, szKey[], iKeyLen, szValue[], iValueLen, any:output[], iOutputLen, const any:fallback[] = {0.0, 0.0})
{
    switch ( iType )
    {
        case DTYPE_FLOAT_RANGE:
        {
            strtok(szValue, szKey, iKeyLen, szValue, iValueLen, ' ')
            output[0] = str_to_float(szKey)
            output[1] = str_to_float(szValue)

            if ( output[0] < 0.0 ) output[0] = fallback[0]
            if ( output[1] < 0.0 ) output[1] = fallback[1]
        }
        case DTYPE_FLOAT:
        {
            output[0] = str_to_float(szValue)
            if ( output[0] < 0.0 ) output[0] = fallback[0]
        }
        case DTYPE_INT_RANGE:
        {
            strtok(szValue, szKey, iKeyLen, szValue, iValueLen, ' ')
            output[0] = str_to_num(szKey)
            output[1] = str_to_num(szValue)

            if ( output[0] < 0 ) output[0] = fallback[0]
            if ( output[1] < 0 ) output[1] = fallback[1]
        }
        case DTYPE_INT:
        {
            output[0] = str_to_num(szValue)
            if ( output[0] < 0 ) output[0] = fallback[0]
        }
        case DTYPE_BOOL:
        {
            output[0] = bool:str_to_num(szValue)
        }
        case DTYPE_FLAGS:
        {
            output[0] = read_flags(szValue)
        }
        case DTYPE_VECTOR:
        {
            strtok(szValue, szKey, iKeyLen, szValue, iValueLen, ' ')
            output[0] = str_to_num(szKey)

            strtok(szValue, szKey, iKeyLen, szValue, iValueLen, ' ')
            output[1] = str_to_num(szKey)
            output[2] = str_to_num(szValue)
        }
        case DTYPE_VECTOR_4:
        {
            strtok(szValue, szKey, iKeyLen, szValue, iValueLen, ' ')
            output[0] = str_to_num(szKey)

            strtok(szValue, szKey, iKeyLen, szValue, iValueLen, ' ')
            output[1] = str_to_num(szKey)

            strtok(szValue, szKey, iKeyLen, szValue, iValueLen, ' ')
            output[2] = str_to_num(szKey)
            output[3] = str_to_num(szValue)
        }
        case DTYPE_STRING_MODEL:
        {
            copy(output, iOutputLen, szValue)
            if ( !g_bFileWasRead ) precache_model(szValue)
        }
        case DTYPE_STRING_SOUND:
        {
            copy(output, iOutputLen, szValue)
            if ( !g_bFileWasRead ) precache_sound(szValue)
        }
        case DTYPE_STRING_SPRITE:
        {
            if ( !g_bFileWasRead )
                output[0] = precache_model(szValue)
        }
    }
}

stock LogConfigError(const iLine, const szText[], any:...)
{
    new szError[MAX_PLATFORM_PATH_LENGTH]
    vformat(szError, charsmax(szError), szText, 3)

    log_to_file(ERROR_FILE, "^nLine %d: %s", iLine, szError)
}
