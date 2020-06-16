#include "highlighter.h"
Highlighter::Highlighter(QTextDocument *parent):QSyntaxHighlighter(parent){
    keywordFormat.setForeground(Qt::blue);
    keywordFormat.setFontWeight(QFont::Bold);
    const QString keywordPatterns[] = {
            QStringLiteral("\\badd\\b"), QStringLiteral("\\baddi\\b"), QStringLiteral("\\bsub\\b"),
            QStringLiteral("\\bsubi\\b"), QStringLiteral("\\band\\b"), QStringLiteral("\\bandi\\b"),
            QStringLiteral("\\bor\\b"), QStringLiteral("\\bori\\b"), QStringLiteral("\\blw\\b"),
            QStringLiteral("\\bsw\\b"), QStringLiteral("\\bjr\\b"), QStringLiteral("\\baddu\\b"),
            QStringLiteral("\\baddiu\\b"), QStringLiteral("\\bsll\\b"), QStringLiteral("\\bslt\\b"),
            QStringLiteral("\\bsra\\b"), QStringLiteral("\\bsrl\\b"), QStringLiteral("\\blui\\b"),
            QStringLiteral("\\bnor\\b"), QStringLiteral("\\bxor\\b"), QStringLiteral("\\bj\\b"),
            QStringLiteral("\\bjal\\b"), QStringLiteral("\\bbeq\\b"), QStringLiteral("\\bbne\\b"),
            QStringLiteral("\\blb\\b"), QStringLiteral("\\blh\\b"), QStringLiteral("\\bsb\\b"),
            QStringLiteral("\\bsh\\b"), QStringLiteral("\\bnop\\b"),  QStringLiteral("\\bsyscall\\b"),
            QStringLiteral("\\bladdri\\b"), QStringLiteral("\\bldatai\\b"),  QStringLiteral("\\bldata\\b"),
            QStringLiteral("\\bldata\\b"), QStringLiteral("\\bdreq\\b"),
            QStringLiteral("\\brst\\b"), QStringLiteral("\\brstb\\b"),  QStringLiteral("\\bsiow\\b"),
            QStringLiteral("\\briow\\b"), QStringLiteral("\\bsior\\b"),  QStringLiteral("\\brior\\b"),
            QStringLiteral("\\bsmemw\\b"), QStringLiteral("\\brmemw\\b"),  QStringLiteral("\\bsmemr\\b"),
            QStringLiteral("\\brmemr\\b"), QStringLiteral("\\bsdm\\b"),  QStringLiteral("\\bsrf\\b"),
            QStringLiteral("\\bmemio\\b"), QStringLiteral("\\biomem\\b"),  QStringLiteral("\\blbus\\b"),
            QStringLiteral("\\bstrtdma\\b"),  QStringLiteral("\\bendma\\b"),
            QStringLiteral("\\bsdemand\\b"),  QStringLiteral("\\brdemand\\b"),
    };
    regFormat.setForeground(Qt::darkMagenta);
    const QString regPatterns[] = {
            QStringLiteral("\\bzero\\b"), QStringLiteral("\\bat\\b"),
            QStringLiteral("\\bv0\\b"), QStringLiteral("\\bv1\\b"), QStringLiteral("\\ba0\\b"),
            QStringLiteral("\\ba1\\b"), QStringLiteral("\\ba2\\b"), QStringLiteral("\\ba3\\b"),
            QStringLiteral("\\bt0\\b"), QStringLiteral("\\bt1\\b"), QStringLiteral("\\bt2\\b"),
            QStringLiteral("\\bt3\\b"), QStringLiteral("\\bt4\\b"), QStringLiteral("\\bt5\\b"),
            QStringLiteral("\\bt6\\b"), QStringLiteral("\\bt7\\b"), QStringLiteral("\\bs0\\b"),
            QStringLiteral("\\bs1\\b"), QStringLiteral("\\bs2\\b"), QStringLiteral("\\bs3\\b"),
            QStringLiteral("\\bs4\\b"), QStringLiteral("\\bs5\\b"), QStringLiteral("\\bs6\\b"),
            QStringLiteral("\\bs7\\b"), QStringLiteral("\\bt8\\b"), QStringLiteral("\\bt9\\b"),
            QStringLiteral("\\bk0\\b"), QStringLiteral("\\bk1\\b"), QStringLiteral("\\bgp\\b"),
            QStringLiteral("\\bsp\\b"), QStringLiteral("\\bfp\\b"), QStringLiteral("\\bra\\b"),
            QStringLiteral("\\bCAR0\\b"), QStringLiteral("\\bCAR1\\b"), QStringLiteral("\\bCAR2\\b"),
            QStringLiteral("\\bCAR3\\b"), QStringLiteral("\\bCCR0\\b"), QStringLiteral("\\bCCR1\\b"),
            QStringLiteral("\\bCCR2\\b"), QStringLiteral("\\bCCR3\\b"), QStringLiteral("\\bCOMMAND\\b"),
            QStringLiteral("\\bMODE0\\b"), QStringLiteral("\\bMODE1\\b"), QStringLiteral("\\bMODE2\\b"),
            QStringLiteral("\\bMODE3\\b")
    };

    HighlightingRule rule;
    for (const QString &pattern : keywordPatterns) {
            rule.pattern = QRegularExpression(pattern);
            rule.format = keywordFormat;
            highlightingRules.append(rule);
    }

    for(const QString &pattern : regPatterns){
        rule.pattern = QRegularExpression(pattern);
        rule.format = regFormat;
        highlightingRules.append(rule);
    }

    singleLineCommentFormat.setForeground(Qt::darkGreen);
    rule.pattern = QRegularExpression(QStringLiteral("#[^\n]*"));
    rule.format = singleLineCommentFormat;
    highlightingRules.append(rule);

    assemblyLabelFormat.setForeground(Qt::darkRed);
    assemblyLabelFormat.setFontWeight(QFont::Bold);
    rule.pattern = QRegularExpression(QStringLiteral("\\w+:"));
    rule.format = assemblyLabelFormat;
    highlightingRules.append(rule);

    numbersFormat.setForeground(Qt::darkCyan);
    rule.pattern = QRegularExpression(QStringLiteral("\\d*$"));
    rule.format = numbersFormat;
    highlightingRules.append(rule);
}

void Highlighter::highlightBlock(const QString &text){
    for(const HighlightingRule &rule : qAsConst(highlightingRules)){
        QRegularExpressionMatchIterator iterator = rule.pattern.globalMatch(text);
        while(iterator.hasNext()){
            QRegularExpressionMatch match = iterator.next();
            setFormat(match.capturedStart(), match.capturedLength(), rule.format);
        }
    }
}
