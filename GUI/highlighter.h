#ifndef HIGHLIGHTER_H
#define HIGHLIGHTER_H

#include <QSyntaxHighlighter>
#include <QRegularExpression>
#include <QDebug>

class Highlighter : public QSyntaxHighlighter{
public:
    Highlighter(QTextDocument *parent = nullptr);

protected:
    void highlightBlock(const QString &text) override;

private:
    struct HighlightingRule{
        QRegularExpression pattern;
        QTextCharFormat format;
    };
    QVector<HighlightingRule> highlightingRules;

    QRegularExpression commentStartExpression;
    QRegularExpression commentEndExpression;

    QTextCharFormat keywordFormat;
    QTextCharFormat regFormat;
    QTextCharFormat singleLineCommentFormat;
    QTextCharFormat assemblyLabelFormat;
    QTextCharFormat numbersFormat;
};

#endif // HIGHLIGHTER_H
