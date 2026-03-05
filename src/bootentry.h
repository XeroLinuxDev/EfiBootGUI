#pragma once
#include <QString>

struct BootEntry {
    QString bootNum;
    QString name;
    bool    active;      // entry is enabled
    bool    isBootNext;  // one-time next boot
    bool    isCurrent;   // this is the running boot entry
};
