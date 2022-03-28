# lib?

This is code related to automated testing & reporting performed by the Pupilfirst LMS.

## Format for `report.json`

This is managed by the `Report` class.

```json
{
  "version": 0,
  "grade": "skip/accept/reject",
  "status": "success/failure",
  "feedback": "Feedback Markdown to send to the student",
  "report": "Report Markdown to show to coaches"
}
```
