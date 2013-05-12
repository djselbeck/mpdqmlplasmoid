#ifndef WHEELAREA_H
#define WHEELAREA_H

#include <QDeclarativeItem>
#include <QGraphicsSceneWheelEvent>

class WheelArea : public QDeclarativeItem
{
    Q_OBJECT

public:
    explicit WheelArea(QDeclarativeItem *parent = 0) : QDeclarativeItem(parent) {}

protected:
    void wheelEvent(QGraphicsSceneWheelEvent *event);

signals:
    void verticalWheel(int delta);
    void horizontalWheel(int delta);
};

#endif // WHEELAREA_H