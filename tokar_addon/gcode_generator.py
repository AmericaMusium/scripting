import bpy
import math
from mathutils import Vector

class GCodeGenerator:
    def __init__(self):
        self.gcode = []
        self.current_position = Vector((0, 0, 0))
        self.current_feed = 0
        self.current_speed = 0
        
    def add_header(self):
        """Добавляет заголовок G-кода"""
        self.gcode.extend([
            "G21", # Миллиметры
            "G90", # Абсолютные координаты
            "G94", # Подача в мм/мин
            "G17", # Выбор плоскости XY
            "G40", # Отмена компенсации радиуса инструмента
            "G49", # Отмена компенсации длины инструмента
            "G80", # Отмена циклов
        ])
        
    def add_footer(self):
        """Добавляет окончание G-кода"""
        self.gcode.extend([
            "M5", # Остановка шпинделя
            "G0 Z50.0", # Подъем инструмента
            "M30", # Конец программы
        ])
        
    def set_feed(self, feed):
        """Устанавливает скорость подачи"""
        if feed != self.current_feed:
            self.current_feed = feed
            self.gcode.append(f"F{feed:.1f}")
            
    def set_speed(self, speed):
        """Устанавливает скорость шпинделя"""
        if speed != self.current_speed:
            self.current_speed = speed
            self.gcode.append(f"S{speed:.0f}")
            self.gcode.append("M3") # Включение шпинделя по часовой стрелке
            
    def rapid_move(self, x=None, y=None, z=None):
        """Быстрое перемещение G0"""
        coords = []
        if x is not None and x != self.current_position.x:
            coords.append(f"X{x:.3f}")
            self.current_position.x = x
        if y is not None and y != self.current_position.y:
            coords.append(f"Y{y:.3f}")
            self.current_position.y = y
        if z is not None and z != self.current_position.z:
            coords.append(f"Z{z:.3f}")
            self.current_position.z = z
            
        if coords:
            self.gcode.append("G0 " + " ".join(coords))
            
    def linear_move(self, x=None, y=None, z=None):
        """Линейное перемещение G1"""
        coords = []
        if x is not None and x != self.current_position.x:
            coords.append(f"X{x:.3f}")
            self.current_position.x = x
        if y is not None and y != self.current_position.y:
            coords.append(f"Y{y:.3f}")
            self.current_position.y = y
        if z is not None and z != self.current_position.z:
            coords.append(f"Z{z:.3f}")
            self.current_position.z = z
            
        if coords:
            self.gcode.append("G1 " + " ".join(coords))
            
    def arc_move(self, x, y, i, j, clockwise=True):
        """Круговое перемещение G2/G3"""
        cmd = "G2" if clockwise else "G3"
        self.gcode.append(f"{cmd} X{x:.3f} Y{y:.3f} I{i:.3f} J{j:.3f}")
        self.current_position.x = x
        self.current_position.y = y
        
    def generate_turning_path(self, obj, settings):
        """Генерирует траекторию для токарной обработки"""
        self.add_header()
        
        # Установка скорости и подачи
        self.set_speed(settings.spindle_speed)
        self.set_feed(settings.feed_rate)
        
        # Безопасный подход
        self.rapid_move(z=50.0)
        self.rapid_move(x=0, y=0)
        
        # Получаем размеры объекта
        dimensions = obj.dimensions
        length = dimensions.x
        diameter = dimensions.y
        
        # Черновая обработка
        current_depth = 0
        while current_depth < diameter/2:
            current_depth += settings.cut_depth
            if current_depth > diameter/2:
                current_depth = diameter/2
                
            # Подход к начальной точке
            self.rapid_move(x=0, z=50.0)
            self.rapid_move(x=0, z=current_depth)
            
            # Проход вдоль детали
            self.linear_move(x=length)
            
            # Отвод
            self.rapid_move(z=50.0)
            
        self.add_footer()
        return self.gcode

def save_gcode(filename, gcode):
    """Сохраняет G-код в файл"""
    with open(filename, 'w') as f:
        f.write('\n'.join(gcode)) 