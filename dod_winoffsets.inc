/* 
* DoD Windows Offsets
* Автор: AI Assistant
* Описание: Файл содержит оффсеты для Day of Defeat для использования с Ham_Sandwich
* Все значения разделены на 4 для совместимости с Ham_Sandwich
*
* ПРИМЕРЫ ИСПОЛЬЗОВАНИЯ:
*
* 1. Урон по телу (m_bodyDamage):
* Используется для определения и установки урона по разным частям тела.
* Значение представляет собой битовую маску, где каждый бит отвечает за определенную часть тела.
* 
* Пример использования:
* new bodyDamage = get_pdata_int(victim, m_bodyDamage)
* if(bodyDamage & (1<<HIT_HEAD)) { // Попадание в голову
*     damage *= 2.0 // Увеличиваем урон
* }
*
* Биты частей тела:
* 1 << 0 - Общий урон
* 1 << 1 - Голова (множитель урона x3)
* 1 << 2 - Грудь (множитель урона x1.25)
* 1 << 3 - Живот (множитель урона x1.1)
* 1 << 4 - Левая рука (множитель урона x1)
* 1 << 5 - Правая рука (множитель урона x1)
* 1 << 6 - Левая нога (множитель урона x0.75)
* 1 << 7 - Правая нога (множитель урона x0.75)
*
* 2. Здоровье (m_rrHealth):
* Используется для работы со здоровьем сущности.
* Тип: float - позволяет использовать дробные значения здоровья.
*
* Пример использования:
* // Получить текущее здоровье
* new Float:health = get_pdata_float(entity, m_rrHealth)
* 
* // Установить здоровье
* set_pdata_float(entity, m_rrHealth, 100.0)
*
* 3. Состояние оружия (m_iWeaponState):
* Определяет текущее состояние оружия игрока.
* Тип: int - битовая маска состояний
*
* Пример использования:
* new weaponState = get_pdata_int(weapon, m_iWeaponState)
* if(weaponState & DOD_WPNSTATE_DEPLOYED) {
*     // Оружие установлено на сошки
* }
*
* Состояния:
* DOD_WPNSTATE_NONE           0       // Обычное состояние
* DOD_WPNSTATE_DEPLOYED       (1<<0)  // Установлено на сошки
* DOD_WPNSTATE_DEPLOYING     (1<<1)  // В процессе установки
* DOD_WPNSTATE_UNDEPLOYING   (1<<2)  // В процессе снятия с сошек
* DOD_WPNSTATE_ZOOM          (1<<3)  // В режиме прицеливания
* DOD_WPNSTATE_EMPTY         (1<<4)  // Нет патронов
* DOD_WPNSTATE_PRIMED        (1<<5)  // Граната готова к броску
*
* 4. Анимации (m_szAnimExtention):
* Определяет расширение анимации для модели.
* Тип: char[32] - строка с именем анимации
*
* Пример использования:
* new szAnim[32]
* get_pdata_string(player, m_szAnimExtention, szAnim, charsmax(szAnim))
* 
* // Установить анимацию для разных состояний
* set_pdata_string(player, m_szAnimExtention, "garand", charsmax(szAnim))  // Garand
* set_pdata_string(player, m_szAnimExtention, "kar", charsmax(szAnim))     // Kar98
* set_pdata_string(player, m_szAnimExtention, "mg42", charsmax(szAnim))    // MG42
* set_pdata_string(player, m_szAnimExtention, "30cal", charsmax(szAnim))   // 30cal
*
* 5. Контрольные точки (m_iPointState, m_iPointOwner):
* Используются для работы с контрольными точками на карте.
* 
* Пример использования:
* new pointState = get_pdata_int(point, m_iPointState)
* new pointOwner = get_pdata_int(point, m_iPointOwner)
* 
* // Проверка владения точкой
* if(pointOwner == DOD_TEAM_ALLIES) {
*     // Точка принадлежит союзникам
*     if(pointState == DOD_POINT_CAPTURED) {
*         // Точка захвачена полностью
*     }
* }
*
* Команды:
* DOD_TEAM_NONE     0  // Нет команды
* DOD_TEAM_ALLIES   1  // Союзники
* DOD_TEAM_AXIS     2  // Ось
* DOD_TEAM_SPECTATOR 3 // Наблюдатели
*
* Состояния точек:
* DOD_POINT_NEUTRAL    0  // Нейтральная
* DOD_POINT_ALLIES     1  // Захватывается союзниками
* DOD_POINT_AXIS       2  // Захватывается осью
* DOD_POINT_CAPTURED   3  // Полностью захвачена
* 
* 6. Эффекты (m_rrEffects):
* Управление визуальными эффектами сущности.
* Тип: int - битовая маска эффектов
*
* Пример использования:
* new effects = get_pdata_int(entity, m_rrEffects)
* 
* // Добавить эффект дыма
* effects |= DOD_EF_SMOKE
* set_pdata_int(entity, m_rrEffects, effects)
*
* Эффекты:
* DOD_EF_NONE         0       // Нет эффектов
* DOD_EF_SMOKE       (1<<0)  // Дым
* DOD_EF_FLASH       (1<<1)  // Вспышка выстрела
* DOD_EF_NODRAW      (1<<2)  // Невидимость
* DOD_EF_NIGHTVISION (1<<3)  // Ночное видение
*
* 7. Звуки (m_usVoice, m_gerVoice):
* Управление голосовыми командами и звуками.
* Тип: unsigned short - индекс звука
*
* Пример использования:
* new voice = get_pdata_int(player, m_usVoice)
* if(voice & DOD_VOICE_MEDIC) {
*     // Игрок просит медика
*     emit_sound(player, CHAN_VOICE, "player/medic.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
* }
*
* Голосовые команды:
* DOD_VOICE_MEDIC     (1<<0)  // Medic!
* DOD_VOICE_BACKUP    (1<<1)  // Need Backup!
* DOD_VOICE_GRENADE   (1<<2)  // Grenade!
* DOD_VOICE_GOGOGO    (1<<3)  // Go go go!
* DOD_VOICE_CEASEFIRE (1<<4)  // Cease fire!
* DOD_VOICE_ENEMY     (1<<5)  // Enemy spotted!
* DOD_VOICE_SNIPER    (1<<6)  // Sniper!
* DOD_VOICE_THANKS    (1<<7)  // Thanks!
*
* 8. Раунд (m_RoundState, m_flRoundTime):
* Управление состоянием и временем раунда.
*
* Пример использования:
* new roundState = get_pdata_int(gameRules, m_RoundState)
* new Float:roundTime = get_pdata_float(gameRules, m_flRoundTime)
*
* if(roundState == DOD_ROUND_ACTIVE) {
*     // Раунд активен
*     if(roundTime < 10.0) {
*         // Осталось меньше 10 секунд
*         client_print(0, print_center, "До конца раунда: %.1f сек", roundTime)
*     }
* }
*
* Состояния раунда:
* DOD_ROUND_NONE      0  // Нет раунда
* DOD_ROUND_FREEZETIME 1  // Время заморозки
* DOD_ROUND_ACTIVE    2  // Активный раунд
* DOD_ROUND_OVER      3  // Раунд окончен
* DOD_ROUND_RESTART   4  // Перезапуск раунда

* 9. Состояния игрока (m_iPlayerClass, m_iPlayerTeam):
* Управление классом и командой игрока.
*
* Пример использования:
* new playerClass = get_pdata_int(player, m_iPlayerClass)
* new playerTeam = get_pdata_int(player, m_iPlayerTeam)
*
* // Проверка класса и команды
* if(playerTeam == DOD_TEAM_ALLIES) {
*     switch(playerClass) {
*         case DOD_CLASS_GARAND: {
*             // Американский стрелок с Garand
*         }
*         case DOD_CLASS_THOMPSON: {
*             // Американский пулеметчик с Thompson
*         }
*     }
* }
* else if(playerTeam == DOD_TEAM_AXIS) {
*     switch(playerClass) {
*         case DOD_CLASS_KAR: {
*             // Немецкий стрелок с Kar98
*         }
*         case DOD_CLASS_MP40: {
*             // Немецкий пулеметчик с MP40
*         }
*     }
* }
*
* Классы союзников:
* DOD_CLASS_GARAND     1  // Стрелок с M1 Garand
* DOD_CLASS_CARBINE    2  // Стрелок с M1 Carbine
* DOD_CLASS_THOMPSON   3  // Пулеметчик с Thompson
* DOD_CLASS_GREASE     4  // Пулеметчик с Grease Gun
* DOD_CLASS_SNIPER     5  // Снайпер со Springfield
* DOD_CLASS_30CAL      6  // Пулеметчик с 30 Cal
* DOD_CLASS_BAR        7  // Пулеметчик с BAR
* DOD_CLASS_BAZOOKA    8  // Базукер
*
* Классы оси:
* DOD_CLASS_KAR        9   // Стрелок с Kar98
* DOD_CLASS_K43        10  // Стрелок с K43
* DOD_CLASS_MP40       11  // Пулеметчик с MP40
* DOD_CLASS_MP44       12  // Пулеметчик с StG 44
* DOD_CLASS_SCHARF     13  // Снайпер с Scoped Kar98
* DOD_CLASS_MG42       14  // Пулеметчик с MG42
* DOD_CLASS_MG34       15  // Пулеметчик с MG34
* DOD_CLASS_PANZERJAGER 16 // Панцерягер с Panzerschreck
*
* 10. Состояния прицеливания (m_iFOV, m_flNextPrimaryAttack):
* Управление прицеливанием и стрельбой.
*
* Пример использования:
* new iFOV = get_pdata_int(player, m_iFOV)
* new Float:nextAttack = get_pdata_float(weapon, m_flNextPrimaryAttack)
*
* // Проверка прицеливания
* if(iFOV != 90) { // Игрок прицеливается
*     // Замедлить игрока
*     set_pev(player, pev_maxspeed, 120.0)
*     
*     // Увеличить точность
*     accuracy *= 1.5
* }
*
* // Проверка возможности стрельбы
* new Float:gameTime = get_gametime()
* if(nextAttack > gameTime) {
*     // Игрок не может стрелять еще (nextAttack - gameTime) секунд
* }
*
* Значения FOV:
* DOD_FOV_NORMAL      90   // Обычный вид
* DOD_FOV_SCOPE       20   // Снайперский прицел
* DOD_FOV_BINOC       35   // Бинокль
*
* 11. Состояния гранат (m_chargeReady, m_flStartThrow):
* Управление подготовкой и броском гранат.
*
* Пример использования:
* new chargeReady = get_pdata_int(grenade, m_chargeReady)
* new Float:throwStart = get_pdata_float(grenade, m_flStartThrow)
*
* // Проверка заряда гранаты
* if(chargeReady & DOD_GREN_PRIMED) {
*     // Граната готова к броску
*     new Float:holdTime = get_gametime() - throwStart
*     
*     if(holdTime > 5.0) {
*         // Слишком долго держит - взрыв в руке!
*         ExecuteHamB(Ham_Killed, player, player, 2)
*     }
*     else {
*         // Рассчитать силу броска
*         new Float:throwForce = min(holdTime * 500.0, 1500.0)
*     }
* }
*
* Состояния гранат:
* DOD_GREN_NONE      0       // Нет гранаты
* DOD_GREN_PRIMED    (1<<0)  // Готова к броску
* DOD_GREN_COOKING   (1<<1)  // Запал выдернут
* DOD_GREN_THROWN    (1<<2)  // Граната брошена
*
* 12. Состояния сошек (m_weaponState для пулеметов):
* Управление установкой пулемета на сошки.
*
* Пример использования:
* new weaponState = get_pdata_int(weapon, m_weaponState)
*
* // Проверка возможности установки сошек
* new Float:origin[3], Float:end[3], Float:angles[3]
* pev(player, pev_origin, origin)
* pev(player, pev_v_angle, angles)
* 
* angle_vector(angles, ANGLEVECTOR_FORWARD, end)
* xs_vec_mul_scalar(end, 32.0, end)
* xs_vec_add(origin, end, end)
*
* new tr = create_tr2()
* engfunc(EngFunc_TraceLine, origin, end, DONT_IGNORE_MONSTERS, player, tr)
* new Float:fraction
* get_tr2(tr, TR_flFraction, fraction)
* free_tr2(tr)
*
* if(fraction < 1.0) { // Есть поверхность для установки
*     if(!(weaponState & DOD_WPNSTATE_DEPLOYED)) {
*         // Можно установить сошки
*         weaponState |= DOD_WPNSTATE_DEPLOYING
*         set_pdata_int(weapon, m_weaponState, weaponState)
*         
*         // Запустить анимацию установки
*         UTIL_PlayAnimation(player, "deploy", 1.0)
*     }
* }
*
* 13. Состояния контрольных точек (m_iPointState, m_flCaptureTime):
* Управление захватом контрольных точек.
*
* Пример использования:
* new pointState = get_pdata_int(point, m_iPointState)
* new Float:captureTime = get_pdata_float(point, m_flCaptureTime)
*
* // Проверка процесса захвата
* if(pointState == DOD_POINT_ALLIES || pointState == DOD_POINT_AXIS) {
*     new Float:remainingTime = captureTime - get_gametime()
*     if(remainingTime > 0.0) {
*         // Точка в процессе захвата
*         new progress = floatround((1.0 - remainingTime / DOD_CAPTURE_TIME) * 100)
*         client_print(0, print_center, "Захват точки: %d%%", progress)
*     }
*     else {
*         // Точка захвачена
*         pointState = (pointState == DOD_POINT_ALLIES) ? DOD_POINT_CAPTURED_ALLIES : DOD_POINT_CAPTURED_AXIS
*         set_pdata_int(point, m_iPointState, pointState)
*     }
* }
*
* Константы захвата:
* DOD_CAPTURE_TIME         5.0   // Время захвата точки
* DOD_CAPTURE_RADIUS      240.0  // Радиус захвата
* DOD_CAPTURE_HEIGHT      128.0  // Высота зоны захвата
*
* Расширенные состояния точек:
* DOD_POINT_NEUTRAL          0  // Нейтральная
* DOD_POINT_ALLIES          1  // Захватывается союзниками
* DOD_POINT_AXIS            2  // Захватывается осью
* DOD_POINT_CAPTURED_ALLIES  3  // Захвачена союзниками
* DOD_POINT_CAPTURED_AXIS    4  // Захвачена осью
* DOD_POINT_BLOCKED         5  // Блокирована (присутствуют обе команды)
*
* 14. Состояния раунда и очков (m_RoundState, m_iTeamScores):
* Управление состоянием раунда и подсчетом очков.
*
* Пример использования:
* new roundState = get_pdata_int(gameRules, m_RoundState)
* new alliesScore = get_pdata_int(gameRules, m_iTeamScores + DOD_TEAM_ALLIES)
* new axisScore = get_pdata_int(gameRules, m_iTeamScores + DOD_TEAM_AXIS)
*
* switch(roundState) {
*     case DOD_ROUND_FREEZETIME: {
*         // Время заморозки - запретить движение
*         for(new i = 1; i <= maxplayers; i++) {
*             if(is_user_alive(i)) {
*                 set_pev(i, pev_maxspeed, 1.0)
*             }
*         }
*     }
*     case DOD_ROUND_ACTIVE: {
*         // Проверка условий победы
*         if(alliesScore >= DOD_WIN_SCORE) {
*             // Победа союзников
*             DOD_EndRound(DOD_TEAM_ALLIES)
*         }
*         else if(axisScore >= DOD_WIN_SCORE) {
*             // Победа оси
*             DOD_EndRound(DOD_TEAM_AXIS)
*         }
*     }
*     case DOD_ROUND_OVER: {
*         // Показать статистику раунда
*         Show_RoundStats()
*     }
* }
*
* Константы очков:
* DOD_SCORE_KILL           1  // Очки за убийство
* DOD_SCORE_TEAMKILL      -1  // Очки за убийство своих
* DOD_SCORE_CAPTURE        2  // Очки за захват точки
* DOD_SCORE_DEFEND         1  // Очки за защиту точки
* DOD_WIN_SCORE           10  // Очки для победы
*
* 15. Состояния оружия (m_iWeaponState, m_flNextPrimaryAttack):
* Расширенное управление оружием.
*
* Пример использования:
* new weaponState = get_pdata_int(weapon, m_iWeaponState)
* new Float:nextAttack = get_pdata_float(weapon, m_flNextPrimaryAttack)
*
* // Проверка возможности стрельбы
* if(weaponState & DOD_WPNSTATE_EMPTY) {
*     // Нет патронов - перезарядка
*     ExecuteHam(Ham_Weapon_Reload, weapon)
* }
* else if(weaponState & DOD_WPNSTATE_DEPLOYED) {
*     // Оружие на сошках - уменьшить разброс
*     nextAttack *= 0.75 // Увеличить скорострельность
*     set_pdata_float(weapon, m_flNextPrimaryAttack, nextAttack)
* }
*
* Дополнительные состояния оружия:
* DOD_WPNSTATE_RELOADING    (1<<6)  // В процессе перезарядки
* DOD_WPNSTATE_EXHAUSTED    (1<<7)  // Перегрев (для MG42/30Cal)
* DOD_WPNSTATE_PRONE        (1<<8)  // Игрок лежит
* DOD_WPNSTATE_LASTROUND    (1<<9)  // Последний патрон
* DOD_WPNSTATE_SILENCED     (1<<10) // С глушителем
* DOD_WPNSTATE_SECONDARY    (1<<11) // Второй режим стрельбы
*
* 16. Состояния игрока (m_iPlayerState):
* Управление состоянием игрока.
*
* Пример использования:
* new playerState = get_pdata_int(player, m_iPlayerState)
*
* // Проверка состояний
* if(playerState & DOD_PLAYER_PRONE) {
*     // Игрок лежит - уменьшить скорость
*     set_pev(player, pev_maxspeed, 50.0)
* }
* if(playerState & DOD_PLAYER_AIMING) {
*     // Игрок целится - увеличить точность
*     accuracy *= 1.5
* }
* if(playerState & DOD_PLAYER_BLEEDING) {
*     // Игрок истекает кровью - периодический урон
*     new Float:nextBleed = get_pdata_float(player, m_flNextBleed)
*     if(get_gametime() >= nextBleed) {
*         ExecuteHam(Ham_TakeDamage, player, 0, 0, 5.0, DMG_GENERIC)
*         set_pdata_float(player, m_flNextBleed, get_gametime() + 1.0)
*     }
* }
*
* Состояния игрока:
* DOD_PLAYER_NONE        0       // Обычное состояние
* DOD_PLAYER_PRONE      (1<<0)  // Лежит
* DOD_PLAYER_AIMING     (1<<1)  // Целится
* DOD_PLAYER_ZOOMED     (1<<2)  // В прицеле
* DOD_PLAYER_RELOADING  (1<<3)  // Перезаряжается
* DOD_PLAYER_BLEEDING   (1<<4)  // Истекает кровью
* DOD_PLAYER_STUNNED    (1<<5)  // Оглушен
* DOD_PLAYER_SWIMMING   (1<<6)  // Плывет
* DOD_PLAYER_CLIMBING   (1<<7)  // Карабкается

* 17. Специальные правила игры (CSPDoDRules):
* Управление специальными правилами и эффектами игры.
*
* Пример использования:
* // Получение указателя на CSPDoDRules
* new rules = -1
* new ent = -1
* while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "dod_gamerules")) != 0) {
*     rules = ent
*     break
* }
*
* if(rules != -1) {
*     // Включение/выключение различных эффектов
*     new bloodSprite = get_pdata_short(rules, m_spBloodSprite)
*     new smokeFx = get_pdata_short(rules, m_spSmoke)
*     
*     // Включить кровь
*     bloodSprite |= 1
*     set_pdata_short(rules, m_spBloodSprite, bloodSprite)
*     
*     // Отключить дым
*     smokeFx &= ~1
*     set_pdata_short(rules, m_spSmoke, smokeFx)
*     
*     // Отключить трупы
*     set_pdata_short(rules, m_spDeadBodies, 0)
* }
*
* // Другой способ получения указателя на правила
* new gamerules = get_gamerules_pointer()
* if(gamerules) {
*     // Управление эффектами через функцию
*     ToggleGameEffect(gamerules, m_spScreenFades, true)  // Включить затемнение экрана
*     ToggleGameEffect(gamerules, m_spBulletTracers, true)  // Включить трассеры
*     ToggleGameEffect(gamerules, m_spExplosion, false)  // Отключить эффекты взрыва
* }
*
* // Функция для управления эффектами
* stock ToggleGameEffect(rules, effect_offset, bool:enable) {
*     new value = get_pdata_short(rules, effect_offset)
*     if(enable)
*         value |= 1
*     else
*         value &= ~1
*     set_pdata_short(rules, effect_offset, value)
* }
*
* // Пример создания сервисной команды для управления эффектами
* public plugin_init() {
*     register_plugin("DoD Effects Manager", "1.0", "Author")
*     register_concmd("dod_toggle_effect", "Cmd_ToggleEffect", ADMIN_CVAR, "<effect> <0|1>")
* }
*
* public Cmd_ToggleEffect(id, level, cid) {
*     if(!cmd_access(id, level, cid, 3))
*         return PLUGIN_HANDLED
*     
*     new arg[32], effect[32], value
*     read_argv(1, effect, charsmax(effect))
*     read_argv(2, arg, charsmax(arg))
*     value = str_to_num(arg)
*     
*     new gamerules = get_gamerules_pointer()
*     if(!gamerules) {
*         console_print(id, "Не удалось получить указатель на правила игры")
*         return PLUGIN_HANDLED
*     }
*     
*     new effect_offset = -1
*     if(equal(effect, "blood"))
*         effect_offset = m_spBloodSprite
*     else if(equal(effect, "smoke"))
*         effect_offset = m_spSmoke
*     else if(equal(effect, "tracers"))
*         effect_offset = m_spBulletTracers
*     else if(equal(effect, "explosion"))
*         effect_offset = m_spExplosion
*     else if(equal(effect, "bodies"))
*         effect_offset = m_spDeadBodies
*     else {
*         console_print(id, "Неизвестный эффект: %s", effect)
*         return PLUGIN_HANDLED
*     }
*     
*     ToggleGameEffect(gamerules, effect_offset, value ? true : false)
*     console_print(id, "Эффект %s %s", effect, value ? "включен" : "отключен")
*     
*     return PLUGIN_HANDLED
* }
*
* // Получение указателя на правила игры
* stock get_gamerules_pointer() {
*     new ent = -1
*     while((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "dod_gamerules")) != 0) {
*         return ent
*     }
*     return 0
* }
*
* // Пример управления несколькими эффектами сразу
* public SetGraphicsLevel(id, level) {
*     new gamerules = get_gamerules_pointer()
*     if(!gamerules)
*         return
*     
*     switch(level) {
*         case 0: { // Низкие настройки
*             ToggleGameEffect(gamerules, m_spBloodSprite, false)
*             ToggleGameEffect(gamerules, m_spBloodStream, false)
*             ToggleGameEffect(gamerules, m_spBulletTracers, false)
*             ToggleGameEffect(gamerules, m_spSparkShower, false)
*             ToggleGameEffect(gamerules, m_spScreenFades, false)
*             ToggleGameEffect(gamerules, m_spDeadBodies, false)
*             ToggleGameEffect(gamerules, m_spExplosion, false)
*         }
*         case 1: { // Средние настройки
*             ToggleGameEffect(gamerules, m_spBloodSprite, true)
*             ToggleGameEffect(gamerules, m_spBloodStream, false)
*             ToggleGameEffect(gamerules, m_spBulletTracers, true)
*             ToggleGameEffect(gamerules, m_spSparkShower, true)
*             ToggleGameEffect(gamerules, m_spScreenFades, true)
*             ToggleGameEffect(gamerules, m_spDeadBodies, false)
*             ToggleGameEffect(gamerules, m_spExplosion, true)
*         }
*         case 2: { // Высокие настройки
*             ToggleGameEffect(gamerules, m_spBloodSprite, true)
*             ToggleGameEffect(gamerules, m_spBloodStream, true)
*             ToggleGameEffect(gamerules, m_spBulletTracers, true)
*             ToggleGameEffect(gamerules, m_spSparkShower, true)
*             ToggleGameEffect(gamerules, m_spScreenFades, true)
*             ToggleGameEffect(gamerules, m_spDeadBodies, true)
*             ToggleGameEffect(gamerules, m_spExplosion, true)
*         }
*     }
*     
*     client_print(id, print_chat, "Графические настройки установлены на уровень %d", level)
* }
*
* // Пример получения и установки всех эффектов
* public DumpGameEffects(id) {
*     new gamerules = get_gamerules_pointer()
*     if(!gamerules) {
*         console_print(id, "Не удалось получить указатель на правила игры")
*         return
*     }
*     
*     console_print(id, "=== Текущие настройки эффектов ===")
*     console_print(id, "Кровь (спрайт): %d", get_pdata_short(gamerules, m_spBloodSprite) & 1)
*     console_print(id, "Кровь (поток): %d", get_pdata_short(gamerules, m_spBloodStream) & 1)
*     console_print(id, "Трассеры: %d", get_pdata_short(gamerules, m_spBulletTracers) & 1)
*     console_print(id, "Искры: %d", get_pdata_short(gamerules, m_spSparkShower) & 1)
*     console_print(id, "Затемнение экрана: %d", get_pdata_short(gamerules, m_spScreenFades) & 1)
*     console_print(id, "Трупы: %d", get_pdata_short(gamerules, m_spDeadBodies) & 1)
*     console_print(id, "Взрывы: %d", get_pdata_short(gamerules, m_spExplosion) & 1)
*     console_print(id, "Дым: %d", get_pdata_short(gamerules, m_spSmoke) & 1)
*     console_print(id, "Пузырьки: %d", get_pdata_short(gamerules, m_spBubbles) & 1)
*     console_print(id, "Следы пузырьков: %d", get_pdata_short(gamerules, m_spBubbleTrails) & 1)
*     console_print(id, "Осколки: %d", get_pdata_short(gamerules, m_spShards) & 1)
*     console_print(id, "Слетающие каски: %d", get_pdata_short(gamerules, m_spPopHelmet) & 1)
*     console_print(id, "Следы ракет: %d", get_pdata_short(gamerules, m_spRocketTrail) & 1)
* }
*
* // Пример сохранения и загрузки настроек эффектов
* public SaveEffectsSettings(id) {
*     new gamerules = get_gamerules_pointer()
*     if(!gamerules)
*         return
*     
*     // Создаем строку с настройками
*     new settings[32]
*     settings[0] = get_pdata_short(gamerules, m_spBloodSprite) & 1 ? '1' : '0'
*     settings[1] = get_pdata_short(gamerules, m_spBloodStream) & 1 ? '1' : '0'
*     settings[2] = get_pdata_short(gamerules, m_spBulletTracers) & 1 ? '1' : '0'
*     settings[3] = get_pdata_short(gamerules, m_spSparkShower) & 1 ? '1' : '0'
*     settings[4] = get_pdata_short(gamerules, m_spScreenFades) & 1 ? '1' : '0'
*     settings[5] = get_pdata_short(gamerules, m_spDeadBodies) & 1 ? '1' : '0'
*     settings[6] = get_pdata_short(gamerules, m_spExplosion) & 1 ? '1' : '0'
*     settings[7] = get_pdata_short(gamerules, m_spSmoke) & 1 ? '1' : '0'
*     settings[8] = get_pdata_short(gamerules, m_spBubbles) & 1 ? '1' : '0'
*     settings[9] = get_pdata_short(gamerules, m_spBubbleTrails) & 1 ? '1' : '0'
*     settings[10] = get_pdata_short(gamerules, m_spShards) & 1 ? '1' : '0'
*     settings[11] = get_pdata_short(gamerules, m_spPopHelmet) & 1 ? '1' : '0'
*     settings[12] = get_pdata_short(gamerules, m_spRocketTrail) & 1 ? '1' : '0'
*     settings[13] = 0
*     
*     // Сохраняем настройки в файл или клиентскую куку
*     client_cmd(id, "setinfo _dod_effects ^"%s^"", settings)
*     console_print(id, "Настройки эффектов сохранены: %s", settings)
* }
*
* public LoadEffectsSettings(id) {
*     new gamerules = get_gamerules_pointer()
*     if(!gamerules)
*         return
*     
*     // Загружаем настройки из файла или клиентской куки
*     new settings[32]
*     get_user_info(id, "_dod_effects", settings, charsmax(settings))
*     
*     if(settings[0]) {
*         ToggleGameEffect(gamerules, m_spBloodSprite, settings[0] == '1')
*         ToggleGameEffect(gamerules, m_spBloodStream, settings[1] == '1')
*         ToggleGameEffect(gamerules, m_spBulletTracers, settings[2] == '1')
*         ToggleGameEffect(gamerules, m_spSparkShower, settings[3] == '1')
*         ToggleGameEffect(gamerules, m_spScreenFades, settings[4] == '1')
*         ToggleGameEffect(gamerules, m_spDeadBodies, settings[5] == '1')
*         ToggleGameEffect(gamerules, m_spExplosion, settings[6] == '1')
*         ToggleGameEffect(gamerules, m_spSmoke, settings[7] == '1')
*         ToggleGameEffect(gamerules, m_spBubbles, settings[8] == '1')
*         ToggleGameEffect(gamerules, m_spBubbleTrails, settings[9] == '1')
*         ToggleGameEffect(gamerules, m_spShards, settings[10] == '1')
*         ToggleGameEffect(gamerules, m_spPopHelmet, settings[11] == '1')
*         ToggleGameEffect(gamerules, m_spRocketTrail, settings[12] == '1')
*         
*         console_print(id, "Настройки эффектов загружены: %s", settings)
*     }
* }
*/

#if defined _dod_winoffsets_included
  #endinput
#endif
#define _dod_winoffsets_included

// Базовые оффсеты сущности (CBaseEntity)
#define m_pev               1     // Указатель на entvars_t структуру (entvars*)
#define m_pGoalEnt         2     // Указатель на целевую сущность (CBaseEntity*)
#define m_pLink            3     // Указатель на связанную сущность (CBaseEntity*)
#define m_rrOrigin         4     // Вектор позиции (Vector)
#define m_rrMins          7     // Минимальные границы (Vector)
#define m_rrMaxs         10     // Максимальные границы (Vector)
#define m_rrAngles       13     // Углы поворота (Vector)
#define m_rrMovedir      16     // Вектор направления движения (Vector)
#define m_rrSpawnflags   19     // Флаги спавна (int)
#define m_rrSolid        20     // Тип твердости (int)
#define m_rrMovetype     21     // Тип движения (int)
#define m_rrEffects      22     // Эффекты (int)
#define m_rrFlags        23     // Флаги (int)
#define m_rrFrags        24     // Количество фрагов (int)
#define m_rrRendermode   25     // Режим отрисовки (int)
#define m_rrRenderamt    26     // Прозрачность (float)
#define m_rrRendercolor  27     // Цвет отрисовки (Vector)
#define m_rrRenderfx     30     // Эффекты отрисовки (int)
#define m_rrHealth       31     // Здоровье (float)
#define m_rrFrame        32     // Текущий кадр анимации (float)
#define m_rrSpeed        33     // Скорость (float)
#define m_rrTarget       34     // Имя цели (string_t)
#define m_rrTargetname   35     // Имя сущности (string_t)
#define m_rrNetname      36     // Сетевое имя (string_t)
#define m_rrTakedamage   37     // Может ли получать урон (float)
#define m_rrScale        38     // Масштаб (float)
#define m_rrGravity      39     // Гравитация (float)

// Функции обработки событий
#define m_pfnThink       40     // Функция обработки мышления (function*)
#define m_pfnTouch       41     // Функция обработки касания (function*)
#define m_pfnUse         42     // Функция обработки использования (function*)
#define m_pfnBlocked     43     // Функция обработки блокировки (function*)

// Состояние подключения
#define has_disconnected 44     // Флаг отключения игрока (BOOL)

// Типы боеприпасов (все int)
#define ammo_9mm         45     // Патроны 9мм (int)
#define ammo_357         46     // Патроны .357 (int)
#define ammo_bolts       47     // Болты (int)
#define ammo_buckshot    48     // Картечь (int)
#define ammo_rockets     49     // Ракеты (int)
#define ammo_uranium     50     // Уран (int)
#define ammo_hornets     51     // Шершни (int)
#define ammo_argrens     52     // Осколочные гранаты (int)
#define ammo_12mm        53     // Патроны 12мм (int)
#define ammo_16mm        54     // Патроны 16мм (int)
#define ammo_22mm        55     // Патроны 22мм (int)
#define ammo_44mm        56     // Патроны 44мм (int)
#define ammo_55mm        57     // Патроны 55мм (int)
#define ammo_66mm        58     // Патроны 66мм (int)
#define ammo_agrens      59     // Американские гранаты (int)
#define ammo_agrensex    60     // Улучшенные американские гранаты (int)
#define ammo_ggrens      61     // Немецкие гранаты (int)
#define ammo_ggrensex    62     // Улучшенные немецкие гранаты (int)

// Состояние броска гранаты
#define m_flStartThrow   63     // Время начала броска (float)
#define m_flReleaseThrow 64     // Время отпускания гранаты (float)
#define m_chargeReady    65     // Готовность заряда (int)
#define m_fInAttack      66     // В состоянии атаки (int)
#define m_fireState      67     // Состояние стрельбы (int)

// Оффсеты оружия (CBasePlayerWeapon)
#define m_iClip          27     // Патроны в магазине (int)
#define m_fInReload      28     // В процессе перезарядки (int)
#define m_fInSpecialReload 29   // В процессе специальной перезарядки (int)
#define m_flNextPrimaryAttack 30 // Следующая основная атака (float)
#define m_flNextSecondaryAttack 31 // Следующая дополнительная атака (float)
#define m_flTimeWeaponIdle 32   // Время до перехода в режим ожидания (float)
#define m_iPrimaryAmmoType 33   // Тип основных патронов (int)
#define m_iSecondaryAmmoType 34 // Тип дополнительных патронов (int)
#define m_iDefaultAmmo   35     // Патроны по умолчанию (int)

// Оффсеты игрока (CBasePlayer)
#define m_flNextAttack   70     // Следующая атака (float)
#define m_weapons        71     // Битовая маска оружия (int)
#define m_flNextDecalTime 72    // Следующая декаль (float)
#define m_flTimeStepSound 73    // Время шага (float)
#define m_iStepLeft      74     // Левый шаг (int)
#define m_flFieldOfView  75     // Поле зрения (float)
#define m_bloodColor     76     // Цвет крови (int)
#define m_iPlayerTeam    77     // Команда игрока (int)
#define m_iPlayerClass   78     // Класс игрока (int)
#define m_iFOV           79     // Текущее поле зрения (int)
#define m_rgpPlayerItems 80     // Массив предметов игрока (CBasePlayerItem*[])
#define m_pActiveItem    81     // Активный предмет (CBasePlayerItem*)
#define m_pLastItem      82     // Последний предмет (CBasePlayerItem*)
#define m_rgAmmo         83     // Массив боеприпасов (int[])
#define m_szAnimExtention 84    // Расширение анимации (char[32])

// Оффсеты контрольных точек (CControlPoint)
#define m_iPointIndex    90     // Индекс точки (int)
#define m_iPointState    91     // Состояние точки (int)
#define m_iPointOwner    92     // Владелец точки (int)
#define m_flCaptureTime  93     // Время захвата (float)
#define m_flNextTick     94     // Следующий тик (float)
#define m_iCapturingTeam 95     // Захватывающая команда (int)

// Оффсеты раунда (CDodRoundTimer)
#define m_flTimeLimit    100    // Лимит времени (float)
#define m_flRoundEndTime 101    // Время конца раунда (float)
#define m_iRoundState    102    // Состояние раунда (int)
#define m_iRoundWinner   103    // Победитель раунда (int)

// Оффсеты статистики (CDoDStatMgr)
#define m_iKills        110     // Убийства (int)
#define m_iDeaths       111     // Смерти (int)
#define m_iScore        112     // Очки (int)
#define m_iCaps         113     // Захваты (int)
#define m_iDefends      114     // Защиты (int)
#define m_iHeadshots    115     // Попадания в голову (int)

// Оффсеты правил командной игры (CDoDTeamPlay)
#define m_RoundDoesCount      1     // Раунд засчитывается (int)
#define m_DoDCameraState      2     // Состояние камеры (int)
#define m_RoundParaCanJoin    3     // Можно присоединиться к парашютистам (int)
#define m_flGoodToGoTime      4     // Время готовности (float)
#define m_flRoundTime         5     // Время раунда (float)
#define m_flCanJoinTime       6     // Время для присоединения (float)
#define m_flRestartTime       7     // Время рестарта (float)
#define m_flFinalCheckTime    8     // Время финальной проверки (float)
#define m_flDoDMapTime        9     // Время карты (float)
#define m_flAlliesWaveTime    10    // Время волны союзников (float)
#define m_flAxisWaveTime      11    // Время волны оси (float)
#define m_flAlliesRespawn     12    // Респавн союзников (float)
#define m_flAxisRespawn       13    // Респавн оси (float)
#define m_iTeamScores         14    // Очки команд (int[32])
#define m_flSpamResetTime     78    // Время сброса спама (float)
#define m_bClanMatch          79    // Клановый матч (bool)
#define m_bClanMatchActive    80    // Клановый матч активен (bool)
#define m_vKickVotes         90     // Голоса за кик (int)
#define m_vKickSessionState  91     // Состояние сессии кика (int)
#define m_vKickTime         92     // Время кика (float)
#define m_rRoundStartCount   93     // Счетчик начала раунда (float)
#define m_rReadyToUnFreeze   94     // Готовность к разморозке (int)
#define m_iNumAlliesAlive    108    // Количество живых союзников (int)
#define m_iNumAxisAlive      109    // Количество живых оси (int)
#define m_iNumAlliesOnTeam   110    // Количество союзников в команде (int)
#define m_iNumAxisOnTeam     111    // Количество оси в команде (int)

// Оффсеты эффектов (CDoDTeamPlay)
#define m_Camera             112    // Камера (unsigned short)
#define m_usVoice           113    // Голос (unsigned short)
#define m_bodyDamage        114    // Урон по телу (unsigned short)
#define m_roundRestartSound 115    // Звук рестарта раунда (unsigned short)
#define m_gerVoice          116    // Немецкий голос (unsigned short)
#define m_Pain              117    // Боль (unsigned short)
#define m_Smoke             118    // Дым (unsigned short)
#define m_Prone             119    // Лежа (unsigned short)
#define m_BloodSprite       120    // Спрайт крови (unsigned short)
#define m_BloodStream       121    // Поток крови (unsigned short)
#define m_BulletTracers     122    // Трассеры пуль (unsigned short)
#define m_SparkShower       123    // Искры (unsigned short)
#define m_ScreenFades       124    // Затемнение экрана (unsigned short)
#define m_BubbleTrails      125    // След пузырьков (unsigned short)
#define m_Bubbles           126    // Пузырьки (unsigned short)
#define m_Shards            127    // Осколки (unsigned short)
#define m_Explosion         128    // Взрыв (unsigned short)
#define m_PopHelmet         129    // Слетающая каска (unsigned short)
#define m_RoundReset        130    // Сброс раунда (unsigned short)
#define m_RocketTrail       131    // След ракеты (unsigned short)

// Оффсеты состояния раунда (CDoDTeamPlay)
#define m_bIsRoundFrozen         132    // Раунд заморожен (bool)
#define m_DisableDeathMessages   133    // Отключить сообщения о смерти (BOOL)
#define m_DisableDeathPenalty    134    // Отключить штраф за смерть (BOOL)
#define m_RoundState             135    // Состояние раунда (int)
#define m_bRoundRestarting       136    // Раунд перезапускается (BOOL)
#define m_bAwaitingReadyRestart  137    // Ожидание готовности к рестарту (BOOL)
#define m_bHeardAlliesReady      138    // Союзники готовы (BOOL)
#define m_bHeardAxisReady        139    // Ось готова (BOOL)
#define m_flRestartRoundTime     140    // Время до рестарта раунда (float)
#define m_fLogScoresTime         141    // Время логирования очков (float)
#define m_flIntermissionEndTime  142    // Время конца перерыва (float)
#define m_iEndIntermissionButtonHit 143 // Нажата кнопка конца перерыва (BOOL)

// Оффсеты специальных правил (CSPDoDRules)
#define m_spCamera           1     // Камера (unsigned short)
#define m_spVoice           2     // Голос (unsigned short)
#define m_spBodyDamage      3     // Урон по телу (unsigned short)
#define m_spRoundRestartSound 4   // Звук рестарта раунда (unsigned short)
#define m_spGerVoice        5     // Немецкий голос (unsigned short)
#define m_spPain            6     // Боль (unsigned short)
#define m_spSmoke           7     // Дым (unsigned short)
#define m_spBloodSprite     8     // Спрайт крови (unsigned short)
#define m_spProne           9     // Лежа (unsigned short)
#define m_spBloodStream     10    // Поток крови (unsigned short)
#define m_spBulletTracers   11    // Трассеры пуль (unsigned short)
#define m_spSparkShower     12    // Искры (unsigned short)
#define m_spScreenFades     13    // Затемнение экрана (unsigned short)
#define m_spBubbleTrails    14    // След пузырьков (unsigned short)
#define m_spBubbles         15    // Пузырьки (unsigned short)
#define m_spShards          16    // Осколки (unsigned short)
#define m_spExplosion       17    // Взрыв (unsigned short)
#define m_spDeadBodies      18    // Мертвые тела (unsigned short)
#define m_spPopHelmet       19    // Слетающая каска (unsigned short)
#define m_spRoundReset      20    // Сброс раунда (unsigned short)
#define m_spRocketTrail     11    // След ракеты (unsigned short) 