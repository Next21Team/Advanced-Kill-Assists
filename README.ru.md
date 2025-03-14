# Advanced Kill Assists

_[English](README.md) | **Русский**_

![Advanced Kill Assists](images/advanced_kill_assists.png)

AMX Mod X плагин для Counter-Strike.

Добавляет на сервер отображение ассистентов по убийству в списке убитых, при этом не меняя клиентские настройки игроков.
Имеется настройка денежного вознаграждения, которое может получить игрок за помощь в убийстве; переключатель выдачи фрага за ассист; выбор алгоритма для подсчета ассистентов.

Для интеграции с AES необходимо скомпилировать плагин с присутствующим в папке include *aes_v.inc*. При этом в плагине ничего редактировать не требуется.

## Квары
- ```aka_algorithm "1"``` Алгоритм для определения помощников в убийтве. По-умолчанию используется ADVANCED (1).
```c
//		CSSTATSX — эквивалентный CSstatsX алгоритм учёта помощи по убийствам с использованием соответствующего квара. Алгоритм выбирает такого игрока, который нанес больше всего ущерба жертве и не менее допустимого значения, определяемое кваром csstats_sql_assisthp из CSstatsX либо параметром DAMAGE_FOR_ASSIST. Если CSstatsX не установлен, то для просчётов используется значение DAMAGE_FOR_ASSIST.
//		ADVANCED — улучшенная и более справедливая формула, которая выбирает из ряда других ассистентов такого, кто больше всего нанес урона жертве и чей процент урона от общего ущерба от всех составляет не менее DAMAGE_FOR_ASSIST процентов. Этот алгоритм не синхронизируется с CSstatsX, что может повлечь к неучёту их в статистике.
```
- ```aka_frag "1"``` Если значение не равно нулю, игроку, оказавшему помощь в убийстве, будет зачислятся фраг.
- ```aka_money "100"``` Сколько денег платить игроку, совершившему помощь в убийстве. Оплата произойдет только если указано значение больше нуля.
- ```aka_damage "30.0"``` Универсальное значение урона. Его значение определяется алгоритмом ```aka_algorithm```.
- ```aka_exp "0"``` Сколько опыта AES выдавать игроку, совершившему помощь в убийстве.
- ```aka_noffreward "1"``` Если значение не равно нулю, игроку, оказавшему помощь в убийстве товарища по команде (friendly fire), не будет зачислятся фраг, деньги и опыт AES.
- ```aka_chatmessage "1"``` Выводить сообщение в чате игроку, оказавшему помощь в убийстве. Шаблон сообщения содержится в **data/lang/next21_kill_assist.txt**. Поддерживаются специальные вставки:
```c
//		[award]  — Награда за убийство деньгами, которая равна aka_money. Выводится без символа '$'.
//		[exp]    — Награда за убийство опытом, которая равна aka_exp. Работает только с AES.
//		[killer] — Ник игрока, совершившего убийство.
//		[victim] — Ник игрока, который был убит.
//    Значение [exp] работает только при aka_exp > 0 и активированном AES, а значение [award] работает только при aka_money > 0.
//    В противном случае будет выведено пустое значение.
```

## Требования
- [Reapi](https://github.com/s1lentq/reapi)

## Авторы
- [Xelson](https://github.com/Xelson)

## Благодарности
- **Nestle_** за сток для изменения никнеймов игроков
- **PRoSToC0der** за найденные потенциальные баги
- **8dp** за помощь в разработке алгоритма сокращения никнеймов с плавающими размерами
- **Garey** за расследование и выявление причины краша POV демо
- **ReHLDS Team** за плагин [Invisible Spectator](https://dev-cs.ru/threads/1055/)
