Name
----

Bit_Population_Counter


Synopsys
--------

Модуль для подсчёта количества единиц во входном числе.


Specification
-------------

Параметры модуля:
* WIDTH - Разрядность данных

Интерфейс модуля

Входы:
* clk_i  - вход тактовой частоты
* srst_i - входной сигнал синхронного сброса
* data_i [WIDTH] - входные данные
* data_val_i - сигнал валидности входных данных

Выходы:
* data_o [log2(WIDTH)+1] - выходные данные (результат)
* data_val_o - сигнал валидности выходных данных


Description
-----------

Модуль производит преобразование входных данных в выходные один такт.
По окончании обработки модуль поднимает сигнал валидности.
Данные можно передавать каждый такт.


Files
-----

* rtl/bit_population_counter.sv  --  Основной модуль, реализующий заявленный функционал
* tb/tb.sv                       --  Тестбенч, демонстрируюший пример работы модуля
* quartus/TOP.sv                 --  Тестовый модуль верхнего уровня для сборки проекта


TODO
----

* None


Notes
-----

None


Authors
-------

[GorosVi](https://github.com/GorosVi)


Copyright
---------

None

