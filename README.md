Максимизация потока в сети
===========

Это приложение, написанное на руби с использованием фреймворка Ruby on Rails, решает задачу нахождения макимального потока в заданной сети.

На данный момент реализован алгоритм проталкивание предпотока с поднятием в начало и выбором активной вершины, который выполняет эту задачу за время О(V^2sqrt(E)), где V - количество заданных узлов, а E - количество связей(рёбер в графе) между узлами.

Установка
=============

Я использую RVM(Ruby Version Manager) в своих проектах, поэтому лучше установить руби через него, подробную информацию об установке можно найти на сайте https://rvm.io/rvm/install/

Также в данном проекте я использую последний пропатченный руби, который можно установить следующим образом:

rvm install 1.9.3-p392-reailsexpress --patch railsexpress

Дальнейшую информацию по установке я буду выкладывать по мере развития проекта.
