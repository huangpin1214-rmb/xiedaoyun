#!/usr/bin/env python3
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import FancyBboxPatch, Circle, Ellipse, Arc, FancyArrowPatch
import numpy as np
import os

# 设置中文字体
plt.rcParams['font.sans-serif'] = ['Arial Unicode MS', 'Helvetica']
plt.rcParams['axes.unicode_minus'] = False

output_dir = '/tmp/biology_diagrams'
os.makedirs(output_dir, exist_ok=True)

def draw_cell():
    """动物细胞结构示意图"""
    fig, ax = plt.subplots(1, 1, figsize=(6, 5))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('动物细胞结构示意图', fontsize=14, fontweight='bold', pad=10)

    # 细胞膜（椭圆形）
    cell = Ellipse((5, 5), 6, 5, fill=True, facecolor='lightblue', edgecolor='navy', linewidth=2)
    ax.add_patch(cell)

    # 细胞核
    nucleus = Circle((6.5, 6), 1.5, fill=True, facecolor='#FFE4E1', edgecolor='darkred', linewidth=2)
    ax.add_patch(nucleus)
    ax.text(6.5, 6, '细胞核', ha='center', va='center', fontsize=9)

    # 细胞质
    ax.text(4, 5, '细胞质', ha='center', va='center', fontsize=9, color='navy')

    # 线粒体（简图）
    ax.add_patch(Ellipse((3.5, 3.5), 1.2, 0.6, angle=30, fill=False, edgecolor='darkgreen', linewidth=2))
    ax.text(3.5, 2.8, '线粒体', ha='center', va='center', fontsize=8, color='darkgreen')

    # 标注
    ax.annotate('细胞膜', xy=(2, 5), xytext=(0.5, 5),
                fontsize=9, arrowprops=dict(arrowstyle='->', color='navy'))

    plt.tight_layout()
    path = f'{output_dir}/01_animal_cell.png'
    plt.savefig(path, dpi=150, bbox_inches='tight', facecolor='white')
    plt.close()
    print(f'已生成：{path}')

def draw_plant_cell():
    """植物细胞结构示意图"""
    fig, ax = plt.subplots(1, 1, figsize=(6, 5))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('植物细胞结构示意图', fontsize=14, fontweight='bold', pad=10)

    # 细胞壁（方形）
    cell_wall = FancyBboxPatch((1, 2), 6, 5, boxstyle="round,pad=0.1",
                                fill=True, facecolor='lightgreen', edgecolor='darkgreen', linewidth=2)
    ax.add_patch(cell_wall)

    # 细胞膜（略小于细胞壁）
    cell_membrane = FancyBboxPatch((1.3, 2.3), 5.4, 4.4, boxstyle="round,pad=0.05",
                                    fill=True, facecolor='lightblue', edgecolor='blue', linewidth=1.5)
    ax.add_patch(cell_membrane)

    # 细胞核
    nucleus = Circle((7, 5.5), 1, fill=True, facecolor='#FFE4E1', edgecolor='darkred', linewidth=2)
    ax.add_patch(nucleus)
    ax.text(7, 5.5, '细胞核', ha='center', va='center', fontsize=8)

    # 液泡
    vacuole = Ellipse((4, 3.5), 2.5, 1.5, fill=True, facecolor='plum', edgecolor='purple', alpha=0.5, linewidth=2)
    ax.add_patch(vacuole)
    ax.text(4, 3.5, '液泡', ha='center', va='center', fontsize=8, color='purple')

    # 叶绿体
    chloro1 = Ellipse((2.5, 5.5), 0.8, 0.4, fill=True, facecolor='forestgreen', edgecolor='darkgreen', linewidth=1)
    chloro2 = Ellipse((2.5, 4.8), 0.8, 0.4, fill=True, facecolor='forestgreen', edgecolor='darkgreen', linewidth=1)
    ax.add_patch(chloro1)
    ax.add_patch(chloro2)
    ax.text(1.5, 5.15, '叶绿体', ha='center', va='center', fontsize=7, color='darkgreen')

    plt.tight_layout()
    path = f'{output_dir}/02_plant_cell.png'
    plt.savefig(path, dpi=150, bbox_inches='tight', facecolor='white')
    plt.close()
    print(f'已生成：{path}')

def draw_eye():
    """眼球结构示意图"""
    fig, ax = plt.subplots(1, 1, figsize=(8, 5))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 8)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('眼球结构示意图', fontsize=14, fontweight='bold', pad=10)

    # 眼球轮廓（简化）
    eye = Ellipse((6, 4), 8, 5, fill=False, edgecolor='black', linewidth=2)
    ax.add_patch(eye)

    # 角膜
    arc角膜 = Arc((1.8, 4), 2, 3, angle=0, theta1=60, theta2=120, color='brown', linewidth=2)
    ax.add_patch(arc角膜)
    ax.text(1.5, 6, '角膜', fontsize=9, ha='center')

    # 虹膜
    iris = Ellipse((3.5, 4), 1.2, 2, fill=True, facecolor='brown', edgecolor='#8B4513', linewidth=1.5)
    ax.add_patch(iris)

    # 瞳孔
    pupil = Circle((3.5, 4), 0.5, fill=True, facecolor='black')
    ax.add_patch(pupil)
    ax.text(3.5, 4, '瞳孔', ha='center', va='center', fontsize=7, color='white')

    # 晶状体
    lens = Ellipse((5, 4), 1, 2.5, fill=True, facecolor='lightyellow', edgecolor='orange', linewidth=2, alpha=0.8)
    ax.add_patch(lens)
    ax.text(5, 4, '晶状体', ha='center', va='center', fontsize=8)

    # 视网膜
    retina_path = patches.Arc((10, 4), 5, 3, angle=0, theta1=70, theta2=110, color='red', linewidth=2)
    ax.add_patch(retina_path)
    ax.text(10.5, 4, '视网膜', fontsize=9, ha='left', color='red')

    # 视神经
    ax.annotate('', xy=(11.5, 4), xytext=(10.5, 4),
                arrowprops=dict(arrowstyle='->', color='yellow', lw=2))
    ax.text(11.5, 4, '视神经', fontsize=8, ha='left')

    # 标注
    ax.annotate('①角膜', xy=(2, 6.5), fontsize=8, ha='center')
    ax.annotate('②晶状体', xy=(5, 6.5), fontsize=8, ha='center')
    ax.annotate('③视网膜', xy=(8.5, 6.5), fontsize=8, ha='center')

    plt.tight_layout()
    path = f'{output_dir}/03_eye.png'
    plt.savefig(path, dpi=150, bbox_inches='tight', facecolor='white')
    plt.close()
    print(f'已生成：{path}')

def draw_reflex_arc():
    """反射弧结构示意图"""
    fig, ax = plt.subplots(1, 1, figsize=(10, 4))
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 6)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('反射弧结构示意图', fontsize=14, fontweight='bold', pad=10)

    # 感受器
    ax.add_patch(FancyBboxPatch((0.5, 2.5), 1.5, 1, boxstyle="round,pad=0.1",
                                fill=True, facecolor='lightyellow', edgecolor='orange', linewidth=2))
    ax.text(1.25, 3, '感受器', ha='center', va='center', fontsize=9)

    # 传入神经
    ax.annotate('', xy=(3.5, 3), xytext=(2, 3),
                arrowprops=dict(arrowstyle='->', color='red', lw=2))
    ax.text(2.75, 3.4, '①传入神经', fontsize=8, ha='center', color='red')

    # 神经中枢（脊髓）
    ax.add_patch(FancyBboxPatch((3.5, 1.5), 2.5, 3, boxstyle="round,pad=0.1",
                                fill=True, facecolor='pink', edgecolor='purple', linewidth=2))
    ax.text(4.75, 3, '神经中枢\n(脊髓)', ha='center', va='center', fontsize=9)

    # 传出神经
    ax.annotate('', xy=(7.5, 3), xytext=(6, 3),
                arrowprops=dict(arrowstyle='->', color='blue', lw=2))
    ax.text(6.75, 3.4, '③传出神经', fontsize=8, ha='center', color='blue')

    # 效应器
    ax.add_patch(FancyBboxPatch((7.5, 2.5), 1.5, 1, boxstyle="round,pad=0.1",
                                fill=True, facecolor='lightgreen', edgecolor='darkgreen', linewidth=2))
    ax.text(8.25, 3, '效应器', ha='center', va='center', fontsize=9)

    # 箭头说明
    ax.annotate('', xy=(10, 3), xytext=(9, 3),
                arrowprops=dict(arrowstyle='->', color='green', lw=2))
    ax.text(9.5, 3.6, '神经冲动\n传导方向', fontsize=7, ha='center', color='green')

    # 标注序号
    ax.text(1.25, 4.5, '①', fontsize=10, ha='center', color='red')
    ax.text(4.75, 4.8, '②', fontsize=10, ha='center', color='purple')
    ax.text(8.25, 4.5, '④', fontsize=10, ha='center', color='blue')

    plt.tight_layout()
    path = f'{output_dir}/04_reflex_arc.png'
    plt.savefig(path, dpi=150, bbox_inches='tight', facecolor='white')
    plt.close()
    print(f'已生成：{path}')

def draw_food_web():
    """生态系统食物网示意图"""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('生态系统食物网示意图', fontsize=14, fontweight='bold', pad=10)

    # 生产者 - 草
    ax.add_patch(FancyBboxPatch((5, 0.5), 2, 1, boxstyle="round,pad=0.1",
                                fill=True, facecolor='green', edgecolor='darkgreen', linewidth=2))
    ax.text(6, 1, '草(生产者)', ha='center', va='center', fontsize=9, color='white')

    # 初级消费者 - 兔
    ax.add_patch(FancyBboxPatch((2, 3), 2, 1, boxstyle="round,pad=0.1",
                                fill=True, facecolor='orange', edgecolor='darkorange', linewidth=2))
    ax.text(3, 3.5, '兔', ha='center', va='center', fontsize=9, color='white')

    # 初级消费者 - 蝗虫
    ax.add_patch(FancyBboxPatch((8, 3), 2, 1, boxstyle="round,pad=0.1",
                                fill=True, facecolor='orange', edgecolor='darkorange', linewidth=2))
    ax.text(9, 3.5, '蝗虫', ha='center', va='center', fontsize=9, color='white')

    # 次级消费者 - 青蛙
    ax.add_patch(FancyBboxPatch((5, 5.5), 2, 1, boxstyle="round,pad=0.1",
                                fill=True, facecolor='red', edgecolor='darkred', linewidth=2))
    ax.text(6, 6, '青蛙', ha='center', va='center', fontsize=9, color='white')

    # 三级消费者 - 蛇
    ax.add_patch(FancyBboxPatch((9, 7.5), 2, 1, boxstyle="round,pad=0.1",
                                fill=True, facecolor='purple', edgecolor='darkviolet', linewidth=2))
    ax.text(10, 8, '蛇', ha='center', va='center', fontsize=9, color='white')

    # 顶级消费者 - 鹰
    ax.add_patch(FancyBboxPatch((2, 7.5), 2, 1, boxstyle="round,pad=0.1",
                                fill=True, facecolor='darkblue', edgecolor='navy', linewidth=2))
    ax.text(3, 8, '鹰', ha='center', va='center', fontsize=9, color='white')

    # 分解者
    ax.add_patch(FancyBboxPatch((10, 0.5), 1.5, 1, boxstyle="round,pad=0.1",
                                fill=True, facecolor='gray', edgecolor='black', linewidth=2))
    ax.text(10.75, 1, '分解者', ha='center', va='center', fontsize=8, color='white')

    # 箭头 - 草到兔
    ax.annotate('', xy=(3, 3.2), xytext=(5.5, 1.5),
                arrowprops=dict(arrowstyle='->', color='brown', lw=1.5))

    # 箭头 - 草到蝗虫
    ax.annotate('', xy=(8.2, 3.2), xytext=(6.5, 1.5),
                arrowprops=dict(arrowstyle='->', color='brown', lw=1.5))

    # 箭头 - 蝗虫到青蛙
    ax.annotate('', xy=(6.2, 5.5), xytext=(8.5, 3.2),
                arrowprops=dict(arrowstyle='->', color='brown', lw=1.5))

    # 箭头 - 兔到蛇
    ax.annotate('', xy=(9.2, 7.7), xytext=(4, 3.2),
                arrowprops=dict(arrowstyle='->', color='brown', lw=1.5))

    # 箭头 - 青蛙到蛇
    ax.annotate('', xy=(9.2, 7.7), xytext=(6.5, 5.7),
                arrowprops=dict(arrowstyle='->', color='brown', lw=1.5))

    # 箭头 - 蛇到鹰
    ax.annotate('', xy=(3.8, 7.7), xytext=(9, 7.7),
                arrowprops=dict(arrowstyle='->', color='brown', lw=1.5))

    plt.tight_layout()
    path = f'{output_dir}/05_food_web.png'
    plt.savefig(path, dpi=150, bbox_inches='tight', facecolor='white')
    plt.close()
    print(f'已生成：{path}')

def draw_heart():
    """心脏结构示意图"""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 10)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('心脏结构示意图', fontsize=14, fontweight='bold', pad=10)

    # 左心房
    ax.add_patch(FancyBboxPatch((7, 5), 3, 2.5, boxstyle="round,pad=0.1",
                                fill=True, facecolor='lightcoral', edgecolor='red', linewidth=2))
    ax.text(8.5, 6.25, '②左心房', ha='center', va='center', fontsize=9)

    # 右心房
    ax.add_patch(FancyBboxPatch((2, 5), 3, 2.5, boxstyle="round,pad=0.1",
                                fill=True, facecolor='lightblue', edgecolor='blue', linewidth=2))
    ax.text(3.5, 6.25, '①右心房', ha='center', va='center', fontsize=9)

    # 左心室
    ax.add_patch(FancyBboxPatch((7, 1), 3, 3, boxstyle="round,pad=0.1",
                                fill=True, facecolor='coral', edgecolor='red', linewidth=3))
    ax.text(8.5, 2.5, '④左心室\n(壁最厚)', ha='center', va='center', fontsize=9)

    # 右心室
    ax.add_patch(FancyBboxPatch((2, 1), 3, 3, boxstyle="round,pad=0.1",
                                fill=True, facecolor='lightskyblue', edgecolor='blue', linewidth=2))
    ax.text(3.5, 2.5, '③右心室', ha='center', va='center', fontsize=9)

    # 主动脉
    ax.annotate('', xy=(10, 6.5), xytext=(9, 5),
                arrowprops=dict(arrowstyle='->', color='red', lw=2))
    ax.text(10.5, 6.5, '主动脉', fontsize=8, ha='left', color='red')

    # 肺动脉
    ax.annotate('', xy=(1, 6.5), xytext=(2, 5),
                arrowprops=dict(arrowstyle='->', color='blue', lw=2))
    ax.text(0.5, 6.5, '肺动脉', fontsize=8, ha='left', color='blue')

    # 肺静脉
    ax.annotate('', xy=(7, 6.25), xytext=(6, 6.25),
                arrowprops=dict(arrowstyle='->', color='red', lw=2))
    ax.text(5.5, 6.8, '肺静脉', fontsize=8, ha='right', color='red')

    # 房室瓣
    ax.text(5.5, 5, '⑤房室瓣', fontsize=8, ha='center', color='purple')

    plt.tight_layout()
    path = f'{output_dir}/06_heart.png'
    plt.savefig(path, dpi=150, bbox_inches='tight', facecolor='white')
    plt.close()
    print(f'已生成：{path}')

def draw_leaf_structure():
    """叶片结构示意图"""
    fig, ax = plt.subplots(1, 1, figsize=(8, 6))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('叶片结构示意图', fontsize=14, fontweight='bold', pad=10)

    # 上表皮
    ax.add_patch(FancyBboxPatch((1, 7), 8, 1, fill=True, facecolor='lightyellow', edgecolor='brown', linewidth=2))
    ax.text(5, 7.5, '①上表皮', ha='center', va='center', fontsize=9)

    # 栅栏组织
    ax.add_patch(FancyBboxPatch((1, 4.5), 8, 2.5, fill=True, facecolor='lightgreen', edgecolor='green', linewidth=2))
    ax.text(5, 5.75, '②栅栏组织\n(叶绿体较多)', ha='center', va='center', fontsize=9)

    # 海绵组织
    ax.add_patch(FancyBboxPatch((1, 2), 8, 2.5, fill=True, facecolor='palegreen', edgecolor='green', linewidth=2))
    ax.text(5, 3.25, '③海绵组织', ha='center', va='center', fontsize=9)

    # 下表皮
    ax.add_patch(FancyBboxPatch((1, 0.5), 8, 1.5, fill=True, facecolor='lightyellow', edgecolor='brown', linewidth=2))
    ax.text(5, 1.25, '④下表皮', ha='center', va='center', fontsize=9)

    # 气孔
    ax.add_patch(FancyBboxPatch((4.5, 0.3), 1, 0.4, fill=True, facecolor='white', edgecolor='black', linewidth=1))
    ax.text(5, 0, '⑥气孔', ha='center', va='center', fontsize=8)
    ax.text(5, 0.7, '保卫细胞', ha='center', va='center', fontsize=7)

    # 叶脉
    ax.plot([5, 5], [1, 7], 'brown', linewidth=3)
    ax.text(5.8, 4, '④叶脉', fontsize=9, ha='left', color='brown')

    plt.tight_layout()
    path = f'{output_dir}/07_leaf.png'
    plt.savefig(path, dpi=150, bbox_inches='tight', facecolor='white')
    plt.close()
    print(f'已生成：{path}')

def draw_seed():
    """种子结构示意图"""
    fig, axes = plt.subplots(1, 2, figsize=(10, 5))

    # 菜豆种子
    ax1 = axes[0]
    ax1.set_xlim(0, 6)
    ax1.set_ylim(0, 8)
    ax1.set_aspect('equal')
    ax1.axis('off')
    ax1.set_title('菜豆种子结构', fontsize=12, fontweight='bold')

    # 种皮
    circle1 = Ellipse((3, 4), 4, 6, fill=True, facecolor='tan', edgecolor='brown', linewidth=2)
    ax1.add_patch(circle1)

    # 胚芽
    ax1.add_patch(FancyBboxPatch((2.5, 5.5), 1, 0.8, fill=True, facecolor='lightgreen', edgecolor='green', linewidth=1))
    ax1.text(3, 5.9, '①胚芽', ha='center', va='center', fontsize=8)

    # 胚根
    ax1.add_patch(FancyBboxPatch((2.5, 1.5), 1, 0.8, fill=True, facecolor='lightgreen', edgecolor='green', linewidth=1))
    ax1.text(3, 1.9, '③胚根', ha='center', va='center', fontsize=8)

    # 子叶（两片）
    ax1.add_patch(Ellipse((2.2, 3.5), 0.8, 2.5, fill=True, facecolor='yellow', edgecolor='orange', linewidth=1))
    ax1.add_patch(Ellipse((3.8, 3.5), 0.8, 2.5, fill=True, facecolor='yellow', edgecolor='orange', linewidth=1))
    ax1.text(1.5, 3.5, '④子叶\n(2片)', ha='center', va='center', fontsize=8)

    ax1.text(3, 0.3, '储藏营养', ha='center', va='center', fontsize=7, color='orange')

    # 玉米种子
    ax2 = axes[1]
    ax2.set_xlim(0, 6)
    ax2.set_ylim(0, 8)
    ax2.set_aspect('equal')
    ax2.axis('off')
    ax2.set_title('玉米种子结构', fontsize=12, fontweight='bold')

    # 果皮+种皮
    ellipse2 = Ellipse((3, 4), 4, 6, fill=True, facecolor='tan', edgecolor='brown', linewidth=2)
    ax2.add_patch(ellipse2)

    # 胚乳
    ellipse3 = Ellipse((3.5, 4), 2.5, 4, fill=True, facecolor='lightyellow', edgecolor='yellow', linewidth=1)
    ax2.add_patch(ellipse3)
    ax2.text(3.5, 4, '⑤胚乳\n(储藏营养)', ha='center', va='center', fontsize=8)

    # 胚（较小）
    ax2.add_patch(FancyBboxPatch((1.2, 2.5), 1.2, 2, fill=True, facecolor='lightgreen', edgecolor='green', linewidth=1))
    ax2.text(1.8, 3.5, '胚', ha='center', va='center', fontsize=8)

    # 子叶（1片，较小）
    ax2.add_patch(Ellipse((2.5, 3.5), 0.3, 1.2, fill=True, facecolor='yellow', edgecolor='orange', linewidth=1))
    ax2.text(2.8, 3.5, '⑨子叶\n(1片)', ha='left', va='center', fontsize=7)

    plt.tight_layout()
    path = f'{output_dir}/08_seed.png'
    plt.savefig(path, dpi=150, bbox_inches='tight', facecolor='white')
    plt.close()
    print(f'已生成：{path}')

def draw_digestive_system():
    """人体消化系统示意图"""
    fig, ax = plt.subplots(1, 1, figsize=(10, 7))
    ax.set_xlim(0, 14)
    ax.set_ylim(0, 12)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('人体消化系统示意图', fontsize=14, fontweight='bold', pad=10)

    # 口腔
    ax.add_patch(FancyBboxPatch((1, 8), 2.5, 2, boxstyle="round,pad=0.1",
                                fill=True, facecolor='pink', edgecolor='red', linewidth=2))
    ax.text(2.25, 9, 'A 口腔', ha='center', va='center', fontsize=9)

    # 食道
    ax.add_patch(FancyBboxPatch((2, 5.5), 1, 2.5, fill=True, facecolor='lightsalmon', edgecolor='red', linewidth=2))
    ax.text(2.5, 6.75, 'C\n食道', ha='center', va='center', fontsize=8)

    # 胃
    ax.add_patch(Ellipse((5, 6), 2.5, 3, fill=True, facecolor='lavender', edgecolor='purple', linewidth=2))
    ax.text(5, 6, 'D 胃', ha='center', va='center', fontsize=9)

    # 小肠
    ax.add_patch(FancyBboxPatch((7.5, 3), 3, 5, boxstyle="round,pad=0.1",
                                fill=True, facecolor='mistyrose', edgecolor='red', linewidth=2))
    ax.text(9, 5.5, 'E 小肠\n(消化吸收\n主要场所)', ha='center', va='center', fontsize=8)

    # 大肠
    ax.add_patch(FancyBboxPatch((10.5, 4), 2, 4, boxstyle="round,pad=0.1",
                                fill=True, facecolor='honeydew', edgecolor='green', linewidth=2))
    ax.text(11.5, 6, 'F 大肠', ha='center', va='center', fontsize=9)

    # 肝脏
    ax.add_patch(FancyBboxPatch((4, 9), 2.5, 2, boxstyle="round,pad=0.1",
                                fill=True, facecolor='chocolate', edgecolor='brown', linewidth=2))
    ax.text(5.25, 10, 'G 肝脏', ha='center', va='center', fontsize=9, color='white')

    # 胰腺
    ax.add_patch(FancyBboxPatch((5.5, 3), 2, 1.5, boxstyle="round,pad=0.1",
                                fill=True, facecolor='gold', edgecolor='orange', linewidth=2))
    ax.text(6.5, 3.75, 'H 胰腺', ha='center', va='center', fontsize=8)

    # 阑尾
    ax.add_patch(FancyBboxPatch((12, 2), 1, 1.5, boxstyle="round,pad=0.1",
                                fill=True, facecolor='silver', edgecolor='gray', linewidth=2))
    ax.text(12.5, 2.75, 'I 阑尾', ha='center', va='center', fontsize=8)

    plt.tight_layout()
    path = f'{output_dir}/09_digestive.png'
    plt.savefig(path, dpi=150, bbox_inches='tight', facecolor='white')
    plt.close()
    print(f'已生成：{path}')

# 生成所有图片
print("开始生成生物示意图...")
draw_cell()
draw_plant_cell()
draw_eye()
draw_reflex_arc()
draw_food_web()
draw_heart()
draw_leaf_structure()
draw_seed()
draw_digestive_system()

print(f"\n所有图片已保存到：{output_dir}")
print("共生成9张图片")
